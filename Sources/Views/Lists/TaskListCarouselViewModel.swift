//
//  TaskListCarouselViewModel.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

protocol TaskListCarouselViewModelProtocol {
    var numberOfLists: Int { get }
    func taskFrequency(at index: Int) -> TaskFrequency
    func titleForList(at index: Int) -> String
    func indicatorForList(at index: Int) -> ListControlItem.IndicatorStyle
    func indexPath(from index: Int) -> IndexPath
}

// TODO: Reload the list control when the taskManager updates tasks (through a delegate, or observer, that needs to be written)
// (So that the indicator reloads)

class TaskListCarouselViewModel: TaskListCarouselViewModelProtocol {

    let taskManager: TaskManagerProtocol
    let lists: [TaskFrequency] = [.daily, .weekly, .monthly]

    init(taskManager: TaskManagerProtocol) {
        self.taskManager = taskManager
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
