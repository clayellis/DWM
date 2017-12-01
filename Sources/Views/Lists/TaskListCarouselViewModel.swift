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
    func reloadListControl()
}

class TaskListCarouselViewModel: NSObject, TaskListCarouselViewModelProtocol {

    weak var delegate: TaskListCarouselViewModelDelegate?

    let taskManager: TaskManagerProtocol
    let lists: [TaskFrequency] = [.daily, .weekly, .monthly]

    init(taskManager: TaskManagerProtocol) {
        self.taskManager = taskManager
        super.init()
        self.taskManager.addObserver(self)
    }

    deinit {
        taskManager.removeObserver(self)
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
            // TODO: Create check mark image for completed lists
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
