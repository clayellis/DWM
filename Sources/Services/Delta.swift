//
//  Delta.swift
//  DWM
//
//  Created by Clay Ellis on 11/21/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

struct Delta {
    struct Changes {
        let insertedSections: [IndexSet]
        let deletedSections: [IndexSet]
        let insertedRows: [IndexPath]
        let deletedRows: [IndexPath]
        let movedRows: [(from: IndexPath, to: IndexPath)]

        var hasChanges: Bool {
            return !insertedSections.isEmpty
                || !deletedSections.isEmpty
                || !insertedRows.isEmpty
                || !deletedRows.isEmpty
                || !movedRows.isEmpty
        }

        var onlyHasMovedRowsChanges: Bool {
            return insertedSections.isEmpty
                && deletedSections.isEmpty
                && insertedRows.isEmpty
                && deletedRows.isEmpty
                && !movedRows.isEmpty
        }
    }

    static func changes<T>(between lhs: [[T]], and rhs: [[T]]) -> Changes where T: Hashable  {
        let flattenedLHS = lhs.flatMap { $0 }
        let flattenedRHS = rhs.flatMap { $0 }

        let insertedObjects = Set(flattenedRHS).subtracting(Set(flattenedLHS))
        let deletedObjects = Set(flattenedLHS).subtracting(Set(flattenedRHS))
        let intersectingObjects = Set(flattenedLHS).intersection(Set(flattenedRHS))

        let insertedRows = insertedObjects.flatMap { find($0, in: rhs) }
        let deletedRows = deletedObjects.flatMap { find($0, in: lhs) }
        let movedRows = intersectingObjects.flatMap { object -> (from: IndexPath, to: IndexPath)? in
            guard let from = find(object, in: lhs), let to = find(object, in: rhs), from != to else { return nil }
            return (from: from, to: to)
        }

        let insertedSectionIndices = Set(0 ..< rhs.count).subtracting(Set(0 ..< lhs.count))
        let deletedSectionIndices = Set(0 ..< lhs.count).subtracting(Set(0 ..< rhs.count))

        let insertedSections = insertedSectionIndices.map { IndexSet(integer: $0) }
        let deletedSections = deletedSectionIndices.map { IndexSet(integer: $0) }

        let changes = Changes(insertedSections: insertedSections,
                              deletedSections: deletedSections,
                              insertedRows: insertedRows,
                              deletedRows: deletedRows,
                              movedRows: movedRows)

        return changes
    }

    static private func find<T>(_ object: T, in structure: [[T]]) -> IndexPath? where T: Hashable {
        for (sectionIndex, section) in structure.enumerated() {
            guard let itemIndex = section.index(of: object) else { continue }
            return IndexPath(item: itemIndex, section: sectionIndex)
        }
        return nil
    }
}
