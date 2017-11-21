//
//  DataPopulator.swift
//  DWM
//
//  Created by Clay Ellis on 11/19/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

class DataPopulator {

    typealias Factory = TaskManagerFactory & RecordManagerFactory

    private let factory: Factory

    private lazy var taskManager = factory.makeTaskManager()
    private lazy var recordManager = factory.makeRecordManager()

    init(factory: Factory) {
        self.factory = factory
    }

    func populateData() {
        clearData()
        let d1 = Task(title: "Daily One", frequency: .daily)
        let d2 = Task(title: "Daily Two", frequency: .daily)
        let d3 = Task(title: "Daily Three", frequency: .daily)
        let d4 = Task(title: "Daily Four", frequency: .daily)
        let d5 = Task(title: "Daily Five", frequency: .daily)
        let d6 = Task(title: "Daily Six", frequency: .daily)

        let w1 = Task(title: "Weekly One", frequency: .weekly)
        let w2 = Task(title: "Weekly Two", frequency: .weekly)

        let m1 = Task(title: "Monthly One", frequency: .monthly)
        let m2 = Task(title: "Montly Two", frequency: .monthly)

        [d1, d2, d3, d4, d5, d6, w1, w2, m1, m2].forEach(taskManager.createTask)

        do {
            try recordManager.createCompletionRecord(for: d1)
            try recordManager.createCompletionRecord(for: d2)
        } catch {

        }
    }

    func clearData() {
        taskManager.deleteAllTasks()
    }
}
