//
//  DependencyContainer.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import UIKit

class DependencyContainer {
    private lazy var timeEngine = TimeEngine()

    private lazy var coreDataStack: CoreDataStackProtocol = {
        let coreDataStoreURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Data.sqlite")
        let coreDataStack = try! CoreDataStack(modelLocation: .bundles(Bundle.allBundles), storeLocation: .url(coreDataStoreURL))
        return coreDataStack
    }()

    private lazy var recordDataStore = CoreDataStore<TaskCompletionRecordData>(coreDataStack: coreDataStack)
    private lazy var taskDataStore = CoreDataStore<TaskData>(coreDataStack: coreDataStack)
    private lazy var userDefaultsStore: SimpleStoreProtocol = UserDefaults.standard

    private lazy var dayChangeObserver: DayChangeObserverProtocol = DayChangeObserver(storage: userDefaultsStore, timeEngine: timeEngine)
    private lazy var recordManager: RecordManagerProtocol = RecordManager(timeEngine: timeEngine, recordDataStore: recordDataStore)
    private lazy var taskManager: TaskManagerProtocol = TaskManager(timeEngine: timeEngine, recordManager: recordManager, taskDataStore: taskDataStore)

    private lazy var theme: ThemeProtocol = Themes.default
}

protocol TaskListCarouselFactory {
    func makeTaskListCarouselController() -> TaskListCarouselViewController
    func makeTaskListCarouselViewModel() -> TaskListCarouselViewModelProtocol
    func makeTaskListCarouselView() -> TaskListCarouselViewProtocol & UIView
}

extension DependencyContainer: TaskListCarouselFactory {
    func makeTaskListCarouselView() -> UIView & TaskListCarouselViewProtocol {
        return TaskListCarouselView(factory: self)
    }

    func makeTaskListCarouselViewModel() -> TaskListCarouselViewModelProtocol {
        return TaskListCarouselViewModel()
    }

    func makeTaskListCarouselController() -> TaskListCarouselViewController {
        return TaskListCarouselViewController(factory: self)
    }
}

protocol TaskListFactory {
    func makeEmbeddedTaskListController(for taskFrequency: TaskFrequency) -> TaskListNavigationController
    func makeTaskListController(for taskFrequency: TaskFrequency) -> TaskListViewController
    func makeTaskListViewModel(for taskFrequency: TaskFrequency) -> TaskListViewModelProtocol
    func makeTaskListView() -> TaskListViewProtocol & UIView
}

extension DependencyContainer: TaskListFactory {
    func makeTaskListViewModel(for taskFrequency: TaskFrequency) -> TaskListViewModelProtocol {
        return TaskListViewModel(taskFrequency: taskFrequency, timeEngine: timeEngine, dayChangeObserver: dayChangeObserver, taskManager: taskManager)
    }

    func makeTaskListView() -> UIView & TaskListViewProtocol {
        return TaskListView()
    }

    func makeTaskListController(for taskFrequency: TaskFrequency) -> TaskListViewController {
        return TaskListViewController(factory: self, for: taskFrequency)
    }

    func makeEmbeddedTaskListController(for taskFrequency: TaskFrequency) -> TaskListNavigationController {
        let taskListController = makeTaskListController(for: taskFrequency)
        return TaskListNavigationController(taskListController: taskListController)
    }
}

protocol TaskManagerFactory {
    func makeTaskManager() -> TaskManagerProtocol
}

extension DependencyContainer: TaskManagerFactory {
    func makeTaskManager() -> TaskManagerProtocol {
        return taskManager
    }
}

protocol RecordManagerFactory {
    func makeRecordManager() -> RecordManagerProtocol
}

extension DependencyContainer: RecordManagerFactory {
    func makeRecordManager() -> RecordManagerProtocol {
        return recordManager
    }
}

protocol DataPopulatorFactory {
    func makeDataPopulator() -> DataPopulator
}

extension DependencyContainer: DataPopulatorFactory {
    func makeDataPopulator() -> DataPopulator {
        return DataPopulator(factory: self)
    }
}

protocol SimulatorFactory {
    func makeTimeEngine() -> TimeEngineProtocol
    func makeDayChangeObserver() -> DayChangeObserverProtocol
}

extension DependencyContainer: SimulatorFactory {
    func makeTimeEngine() -> TimeEngineProtocol {
        return timeEngine
    }

    func makeDayChangeObserver() -> DayChangeObserverProtocol {
        return dayChangeObserver
    }
}

protocol ThemeFactory {
    func makeTheme() -> ThemeProtocol
}

extension DependencyContainer: ThemeFactory {
    func makeTheme() -> ThemeProtocol {
        return theme
    }
}
