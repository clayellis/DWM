//
//  Task.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import CoreData

struct Task {
    let id: UUID
    let title: String
    let frequency: TaskFrequency

    init(id: UUID = UUID(), title: String, frequency: TaskFrequency) {
        self.id = id
        self.title = title
        self.frequency = frequency
    }
}

extension Task: Hashable {
    var hashValue: Int {
        return id.hashValue
    }

    static func == (lhs: Task, rhs: Task) -> Bool {
        // FIXME: I'm not sure if every field should be compared to determine equality
        // I think the hashValue of the index should be enough?
        // But that doubt is coming up because I want to disallow duplicate titles.
        // And really we should just disallow duplicate titles in the same list.
        // Because sometimes a user might want "Sweep floors" in daily and monthly
        guard lhs.hashValue == rhs.hashValue else { return false }
        guard lhs.id == rhs.id else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.frequency == rhs.frequency else { return false }
        return true
    }
}

extension Task: CoreDataStorable {
    typealias StoredType = TaskData

    init(from storedObject: StoredType) throws {
        guard let id = storedObject.id,
            let title = storedObject.title,
            let frequencyRawValue = storedObject.frequency
            else {
                throw CoreDataStorableError.storedObjectMissingValuesForProperties(["id", "title", "frequency"])
        }

        self.id = id
        self.title = title
        self.frequency = TaskFrequency(rawValue: frequencyRawValue)!
    }

    func prepareForStorage(in context: NSManagedObjectContext) -> StoredType {
        return TaskData(from: self, in: context)
    }
}
