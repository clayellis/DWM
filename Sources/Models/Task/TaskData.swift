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

extension TaskData {
    public override func prepareForDeletion() {
        // TODO: Delete associated records
        // I'm fairly certain this is the right way to do this without having to inject the TaskCompletionRecordDataStore
        // Though, the TaskManager should be the one to delete the records, so we might not need to do this here, rather trust that the TaskManager will take care of it
//        let name = String(describing: TaskCompletionRecordData.self)
//        let fetchRequest = NSFetchRequest<TaskCompletionRecordData>(entityName: name)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
//        try managedObjectContext?.execute(deleteRequest)
        super.prepareForDeletion()
    }
}

extension TaskData: Retrievable {
    typealias KeyType = UUID

    static var keyName: String { return "id" }
    var keyValue: UUID { return id! }
}
