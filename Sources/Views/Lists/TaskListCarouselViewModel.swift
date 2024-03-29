//
//  TaskListCarouselViewModel.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

protocol TaskListCarouselViewModelProtocol: class {
    weak var delegate: TaskListCarouselViewModelDelegate? { get set }
    var numberOfLists: Int { get }
    func taskFrequency(at index: Int) -> TaskFrequency
    func titleForList(at index: Int) -> String
    func indicatorForList(at index: Int) -> ListControlItem.IndicatorStyle
    func indexPath(from index: Int) -> IndexPath
}

protocol TaskListCarouselViewModelDelegate: class {
    /// Called when the list control should reload data
    func reloadListControl()
}

class TaskListCarouselViewModel: NSObject, TaskListCarouselViewModelProtocol {

    weak var delegate: TaskListCarouselViewModelDelegate?

    let taskManager: TaskManagerProtocol
    let dayChangeObserver: DayChangeObserverProtocol
    let lists: [TaskFrequency] = [.daily, .weekly, .monthly]

    var dayChangeObservationToken: ObservationToken?

    init(taskManager: TaskManagerProtocol,
         dayChangeObserver: DayChangeObserverProtocol) {
        self.taskManager = taskManager
        self.dayChangeObserver = dayChangeObserver
        super.init()

        self.taskManager.addObserver(self)

        dayChangeObservationToken = self.dayChangeObserver.startObserving { [weak self] in
            self?.delegate?.reloadListControl()
        }
    }

    deinit {
        taskManager.removeObserver(self)
        if let token = dayChangeObservationToken {
            dayChangeObserver.stopObserving(token)
        }
    }

    var numberOfLists: Int {
        return lists.count
    }

    func taskFrequency(at index: Int) -> TaskFrequency {
        return lists[index]
    }

    func titleForList(at index: Int) -> String {
        switch taskFrequency(at: index) {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }

    func indicatorForList(at index: Int) -> ListControlItem.IndicatorStyle {
        let frequency = taskFrequency(at: index)
        let (_, incomplete) = taskManager.partitionedTasks(occuring: frequency)
        if incomplete.count > 0 {
            return .text("\(incomplete.count)")
        } else {
            // TODO: Make check mark image a little smaller and more "round"
            let context = ListControlItem.IndicatorImageContext(
                normalImageName: "CheckWhiteCircle",
                normalHighlightedImageName: "CheckWhiteCircle",
                selectedImageName: "CheckWhite",
                selectedHighlightedImageName: "CheckWhite")
            return .image(context)
        }
    }

    func indexPath(from index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }
}

extension TaskListCarouselViewModel: TaskManagerObserver {
    func tasksDidChange() {
        delegate?.reloadListControl()
    }
}
