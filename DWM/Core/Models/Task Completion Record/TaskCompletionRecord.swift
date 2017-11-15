//
//  TaskCompletionRecord.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import CoreData

/// By keeping completion records, we can track streaks over time.
/// A RecordManager can match records with tasks and return the latest record for a task.
/// Only the latest record for a given task in its frequency matters.
/// If a user marks a task as copmleted and then subsequently marks it as incomplete during the same frequency period, the previous completed record is removed.
struct TaskCompletionRecord {
    /// Identifier for the record
    let id: UUID
    /// Identifier for the task
    let taskID: UUID
    /// When the record was made
    let timestamp: Date

    public init(id: UUID = UUID(), taskID: UUID, timestamp: Date) {
        self.id = id
        self.taskID = taskID
        self.timestamp = timestamp
    }
}

extension TaskCompletionRecord: Equatable {
    static func == (lhs: TaskCompletionRecord, rhs: TaskCompletionRecord) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.taskID == rhs.taskID else { return false }
        guard lhs.timestamp == rhs.timestamp else { return false }
        return true
    }
}

extension TaskCompletionRecord: CoreDataStorable {
    typealias StoredType = TaskCompletionRecordData

    init(from storedObject: StoredType) throws {
        guard let id = storedObject.id,
            let taskID = storedObject.taskID,
            let timestamp = storedObject.timestamp as Date?
            else {
                throw CoreDataStorableError.storedObjectMissingValuesForProperties(["id", "taskID", "timestamp"])
        }

        self.id = id
        self.taskID = taskID
        self.timestamp = timestamp
    }

    func prepareForStorage(in context: NSManagedObjectContext) -> TaskCompletionRecordData {
        return TaskCompletionRecordData(from: self, in: context)
    }
}
