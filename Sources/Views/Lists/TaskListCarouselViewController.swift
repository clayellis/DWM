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
    typealias Factory = TaskListCarouselFactory & TaskListFactory
    let factory: Factory

    let viewModel: TaskListCarouselViewModelProtocol
    let carouselView: TaskListCarouselViewProtocol & UIView

    var taskListControllerCache = [TaskFrequency: TaskListNavigationController]()

    init(factory: Factory) {
        self.factory = factory
        self.viewModel = factory.makeTaskListCarouselViewModel()
        self.carouselView = factory.makeTaskListCarouselView()
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
        configure(collectionView: carouselView.collectionView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        listsView.collectionViewLayout.prepareForCentering(in: view)
    }

    func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(tappedSimulateDayChange(_:)))
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
        let taskFrequency = viewModel.taskFrequency(at: indexPath)
        return taskListController(for: taskFrequency)
    }

    // MARK: Helpers

    func simulateDayChange() {
        if let simulator = (factory as? SimulatorFactory) {
            let timeEngine = simulator.makeTimeEngine()
            timeEngine.now = timeEngine.now.addingTimeInterval(86_400)
            NotificationCenter.default.post(name: .NSCalendarDayChanged, object: nil)
        }
    }
}

// MARK: Selectors

extension TaskListCarouselViewController {
    @objc func tappedSimulateDayChange(_ button: UIBarButtonItem) {
        simulateDayChange()
    }
}

// MARK: Collection View

extension TaskListCarouselViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func configure(collectionView: UICollectionView) {
        collectionView.register(TaskListCarouselCell.self, forCellWithReuseIdentifier: TaskListCarouselCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
//        let horizontalInsets: CGFloat = 20
//        collectionView.contentInset = UIEdgeInsets(top: 5,
//                                                   left: horizontalInsets,
//                                                   bottom: view.safeAreaInsets.bottom,
//                                                   right: horizontalInsets)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfLists
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCarouselCell.reuseIdentifier, for: indexPath) as! TaskListCarouselCell
        let taskFrequency = viewModel.taskFrequency(at: indexPath)
        let taskListController = self.taskListController(for: taskFrequency)
        cell.embdedView = taskListController.view
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width //- collectionView.contentInset.horizontal
        let height = collectionView.bounds.height //- collectionView.contentInset.vertical
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        taskListController(at: indexPath).viewWillAppear(false)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        taskListController(at: indexPath).viewDidDisappear(false)
    }
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
