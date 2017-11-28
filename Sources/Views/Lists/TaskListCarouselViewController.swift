//
//  TaskListCarouselViewController.swift
//  DWM
//
//  Created by Clay Ellis on 11/17/17.
//  Copyright © 2017 Test. All rights reserved.
//

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
        configureNavigationBar()
        configure(listControl: listControl)
        configure(collectionView: carouselView.collectionView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        carouselView.collectionViewLayout.prepareForCentering(in: view)
    }

    func configureNavigationBar() {
        navigationItem.titleView = listControl

//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sim", style: .plain, target: self, action: #selector(tappedSimulateDayChange(_:)))
    }


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

    // MARK: Helpers

    func simulateDayChange() {
        if let simulator = (factory as? SimulatorFactory) {
            let timeEngine = simulator.makeTimeEngine()
            timeEngine.simulateDayChange()
        }
    }
}

// MARK: Selectors

extension TaskListCarouselViewController {
    @objc func tappedSimulateDayChange(_ button: UIBarButtonItem) {
        simulateDayChange()
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

    func listControl(_ listControl: ListControl, didSelectListAt index: Int) {
        let indexPath = viewModel.indexPath(from: index)
        feedbackManager.triggerListChangeFeedback()
        carouselView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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

    // MARK: Scroll View

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        feedbackManager.cancelCompletionTouchDownFeedback()
    }
}
