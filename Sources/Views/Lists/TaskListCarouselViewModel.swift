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
    func taskFrequency(at indexPath: IndexPath) -> TaskFrequency
    func titleForList(at indexPath: IndexPath) -> String
}

class TaskListCarouselViewModel: TaskListCarouselViewModelProtocol {

    var lists: [TaskFrequency] = [.daily, .weekly, .monthly]

    var numberOfLists: Int {
        return lists.count
    }

    func taskFrequency(at indexPath: IndexPath) -> TaskFrequency {
        return lists[indexPath.item]
    }

    func titleForList(at indexPath: IndexPath) -> String {
        switch taskFrequency(at: indexPath) {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
}
