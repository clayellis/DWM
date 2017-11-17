//
//  TaskCompletionRecordData+CoreDataProperties.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskCompletionRecordData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskCompletionRecordData> {
        return NSFetchRequest<TaskCompletionRecordData>(entityName: "TaskCompletionRecordData")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var taskID: UUID?
    @NSManaged public var timestamp: NSDate?

}
