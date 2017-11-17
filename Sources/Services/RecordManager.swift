//
//  RecordManager.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Defines a manager for `TaskCompletionRecord`s
protocol RecordManagerProtocol {
    /// All `TaskCompletionRecord`s
    var records: [TaskCompletionRecord] { get }

    /// Returns all `TaskCompletionRecord`s for a `task`
    func records(for task: Task) -> [TaskCompletionRecord]

    /// Returns the latest `TaskCompletionRecord` for a `task` if one exists
    func latestRecord(for task: Task) -> TaskCompletionRecord?

    /// Returns the latest `TaskCompletionRecord` for a `task` in its current frequency period if one exists
    func latestRecordInCurrentPeriod(for task: Task) -> TaskCompletionRecord?

    /// Creates and returns `TaskCompletionRecord` for a `task` in its current frequency period, throws `RecordManagerError`
    @discardableResult func createCompletionRecord(for task: Task) throws -> TaskCompletionRecord

    /// Removes and returns the latest `TaskCompletionRecord` for a `task` in its current frequency period if one exists
    @discardableResult func removeCompletionRecord(for task: Task) -> TaskCompletionRecord?

    /// Removes all records
    func removeAllCompletionRecords()

    /// Removes all records for a `task` regardless of current frequency period
    func removeAllCompletionRecords(for task: Task)
}

// TODO: Determine the right way for handling errors thrown by internal dependencies.
// Should we create another layer of errors (RecordManagerError) and throw those?
// Or should we handle and log the error right at this level to follow the "best practive" of "handle as close to the call site as possible"

enum RecordManagerError: Error {
    case failedToCreateCompletionRecord
}

final class RecordManager: RecordManagerProtocol {
    let timeEngine: TimeEngineProtocol
    let recordDataStore: CoreDataStore<TaskCompletionRecordData>

    init(timeEngine: TimeEngineProtocol, recordDataStore: CoreDataStore<TaskCompletionRecordData>) {
        self.timeEngine = timeEngine
        self.recordDataStore = recordDataStore
    }

    var records: [TaskCompletionRecord] {
        do {
            return try recordDataStore.retrieveAll()
                .map { try TaskCompletionRecord(from: $0) }
        } catch {
            // TODO: Log the error
            return []
        }
    }

    func records(for task: Task) -> [TaskCompletionRecord] {
        return records.filter { $0.taskID == task.id }
    }

    func latestRecord(for task: Task) -> TaskCompletionRecord? {
        return records(for: task)
            .sorted { $0.timestamp < $1.timestamp }
            .last
    }

    func latestRecordInCurrentPeriod(for task: Task) -> TaskCompletionRecord? {
        do {
            guard let latestRecord = self.latestRecord(for: task),
                try timeEngine.isDate(latestRecord.timestamp, inCurrentPeriodfor: task.frequency)
                else { return nil }
            return latestRecord
        } catch {
            // TODO: Log the error
            return nil
        }
    }

    @discardableResult func createCompletionRecord(for task: Task) throws -> TaskCompletionRecord {
        let record = TaskCompletionRecord(taskID: task.id, timestamp: timeEngine.now)
        let preparedRecord = record.prepareForStorage(in: recordDataStore.context)
        do {
            try recordDataStore.store(preparedRecord)
            return record
        } catch {
            // TODO: Log the error
            throw RecordManagerError.failedToCreateCompletionRecord
        }
    }

    @discardableResult func removeCompletionRecord(for task: Task) -> TaskCompletionRecord? {
        do {
            guard let record = latestRecordInCurrentPeriod(for: task) else { return nil }
            try recordDataStore.deleteEntity(withIdentifier: record.id)
            return record
        } catch {
            // TODO: Log the error
            return nil
        }
    }

    func removeAllCompletionRecords() {
        do {
            try recordDataStore.deleteAll()
        } catch {
            // TODO: Handle the error
        }
    }

    func removeAllCompletionRecords(for task: Task) {
        do {
            let records = try recordDataStore.retrieveAll()
                .filter { $0.taskID == task.id }
            try recordDataStore.delete(records)
        } catch {
            // TODO: Log the error
        }
    }
}
