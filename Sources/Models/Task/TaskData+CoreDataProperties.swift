//
//  TaskData+CoreDataProperties.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskData> {
        return NSFetchRequest<TaskData>(entityName: "TaskData")
    }

    @NSManaged public var frequency: String?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?

}
