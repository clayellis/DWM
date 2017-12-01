//
//  TaskListCarouselViewController.swift
//  DWM
//
//  Created by Clay Ellis on 11/17/17.
//  Copyright © 2017 Test. All rights reserved.
//

// TODO: When a list is completed, the "daily" "weekly" "monthly" list item should scale and move to the center of the screen (filling up like 80% of the width)
// and then the checkmark should appear and confetti pops out with a congrats message or something. The longer the frequency, the more confetti.
// (daily gets a little confetti, weekly gets a lot, monthly gets a ton)

import UIKit

/// A `UIViewController` subclass for presenting task lists
class TaskListCarouselViewController: UIViewController {
    typealias Factory = TaskListCarouselFactory & TaskListFactory & ThemeFactory & FeedbackManagerFactory
    let factory: Factory

    let viewModel: TaskListCarouselViewModelProtocol
    let carouselView: TaskListCarouselViewProtocol & UIView
    let feedbackManager: FeedbackManagerProtocol
    let listControl = ListControl()

    var taskListControllerCache = [TaskFrequency: TaskListNavigationController]()

    var simulateForwardGesture: UISwipeGestureRecognizer?
    var simulateBackwardGesture: UISwipeGestureRecognizer?

    init(factory: Factory) {
        self.factory = factory
        self.viewModel = factory.makeTaskListCarouselViewModel()
        self.carouselView = factory.makeTaskListCarouselView()
        self.feedbackManager = factory.makeFeedbackManager()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = carouselView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configureNavigationBar()
        configure(listControl: listControl)
        configure(collectionView: carouselView.collectionView)
        // TODO: Add a dev and prod configuration and DEV flag to the dev configuration and only execute the following on dev
        configureDevelopmentGestures()
    }

    func configureNavigationBar() {
        navigationItem.titleView = listControl
    }

    func configureDevelopmentGestures() {
        simulateForwardGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSimulationForwardGesture(_:)))
        simulateForwardGesture!.numberOfTouchesRequired = 3
        simulateForwardGesture!.direction = .right
        simulateForwardGesture!.delegate = self
        view.addGestureRecognizer(simulateForwardGesture!)

        simulateBackwardGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSimulationBackwardGesture(_:)))
        simulateBackwardGesture!.numberOfTouchesRequired = 3
        simulateBackwardGesture!.direction = .left
        simulateBackwardGesture!.delegate = self
        view.addGestureRecognizer(simulateBackwardGesture!)
    }

    // MARK: Helpers

    func taskListController(for taskFrequency: TaskFrequency) -> TaskListNavigationController {
        if let cached = taskListControllerCache[taskFrequency] {
            return cached
        } else {
            let controller = factory.makeEmbeddedTaskListController(for: taskFrequency)
            addChildViewController(controller)
            controller.didMove(toParentViewController: self)
            taskListControllerCache[taskFrequency] = controller
            return controller
        }
    }

    func taskListController(at indexPath: IndexPath) -> TaskListNavigationController {
        let taskFrequency = viewModel.taskFrequency(at: indexPath.item)
        return taskListController(for: taskFrequency)
    }

    func simulateDayChange(forward: Bool) {
        if let simulator = (factory as? SimulatorFactory) {
            let timeEngine = simulator.makeTimeEngine()
            timeEngine.simulateDayChange(forward: forward)
        }
    }
}

// MARK: Selectors

extension TaskListCarouselViewController {
    @objc func handleSimulationForwardGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        simulateDayChange(forward: true)
    }

    @objc func handleSimulationBackwardGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        simulateDayChange(forward: false)
    }
}

// MARK: View Model Delegate

extension TaskListCarouselViewController: TaskListCarouselViewModelDelegate {
    func reloadListControl() {
        listControl.reloadData()
    }
}

// MARK: List Control

extension TaskListCarouselViewController: ListControlDataSource, ListControlDelegate {
    func configure(listControl: ListControl) {
        listControl.dataSource = self
        listControl.delegate = self
    }

    func numberOfLists() -> Int {
        return viewModel.numberOfLists
    }

    func listControl(_ listControl: ListControl, titleForListAt index: Int) -> String {
        return viewModel.titleForList(at: index)
    }

    func listControl(_ listControl: ListControl, indicatorStyleForListAt index: Int) -> ListControlItem.IndicatorStyle? {
        return viewModel.indicatorForList(at: index)
    }

    func listControl(_ listControl: ListControl, didSelectListAt index: Int) {
        let indexPath = viewModel.indexPath(from: index)
        feedbackManager.triggerListChangeFeedback()
        carouselView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func listControlCurrentSelectedIndex(_ listControl: ListControl) -> Int? {
        return carouselView.collectionView.currentPage
    }
}

// MARK: Collection View

extension TaskListCarouselViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CarouselCollectionViewDelegate {

    func configure(collectionView: CarouselCollectionView) {
        collectionView.register(TaskListCarouselCell.self, forCellWithReuseIdentifier: TaskListCarouselCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pagingDelegate = self
        collectionView.forceDelaysContentTouches(false)
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfLists
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCarouselCell.reuseIdentifier, for: indexPath) as! TaskListCarouselCell
        let taskFrequency = viewModel.taskFrequency(at: indexPath.item)
        let taskListController = self.taskListController(for: taskFrequency)
        cell.embeddedView = taskListController.view
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        taskListController(at: indexPath).viewWillAppear(false)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        taskListController(at: indexPath).viewDidDisappear(false)
    }

    func collectionView(_ collectionView: CarouselCollectionView, didChangePagesTo page: Int) {
        listControl.selectedIndex = page
        feedbackManager.triggerListChangeFeedback()
    }
}

// MARK: Gesture Recognizer

extension TaskListCarouselViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == simulateForwardGesture || gestureRecognizer == simulateBackwardGesture {
            return true
        } else {
            return false
        }
    }
}
