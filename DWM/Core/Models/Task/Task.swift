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
    var frequency: TaskFrequency

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
        return lhs.hashValue == rhs.hashValue
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
