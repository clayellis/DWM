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
    func indexPath(from index: Int) -> IndexPath
}

class TaskListCarouselViewModel: TaskListCarouselViewModelProtocol {

    var lists: [TaskFrequency] = [.daily, .weekly, .monthly]

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

    func indexPath(from index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }
}
