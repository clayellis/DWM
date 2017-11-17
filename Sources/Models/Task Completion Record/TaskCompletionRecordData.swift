//
//  TaskCompletionRecordData.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import CoreData

extension TaskCompletionRecordData: CoreDataConfigurable {
    typealias ConfiguringType = TaskCompletionRecord

    convenience init(from configuringObject: ConfiguringType, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = configuringObject.id
        self.taskID = configuringObject.taskID
        self.timestamp = configuringObject.timestamp as NSDate
    }
}

extension TaskCompletionRecordData: Retrievable {
    typealias KeyType = UUID

    static var keyName: String { return "id" }
    var keyValue: UUID { return id! }
}
