//
//  TaskData.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import CoreData

extension TaskData: CoreDataConfigurable {
    typealias ConfiguringType = Task

    convenience init(from configuringObject: Task, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = configuringObject.id
        self.title = configuringObject.title
        self.frequency = configuringObject.frequency.rawValue
    }
}

extension TaskData: Retrievable {
    typealias KeyType = UUID

    static var keyName: String { return "id" }
    var keyValue: UUID { return id! }
}
