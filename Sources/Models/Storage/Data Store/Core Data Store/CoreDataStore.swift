//
//  CoreDataStore.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataStoreProtocol: DataStoreProtocol {
    /// `NSManagedObjectContext` backing the store
    var context: NSManagedObjectContext { get }
}

enum CoreDataStoreError: Error {
    case coreDataError(Error)
}

class CoreDataStore<Entity: Retrievable>: CoreDataStoreProtocol where Entity: NSManagedObject {

    private let coreDataStack: CoreDataStackProtocol

    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }

    // MARK: Helpers

    private var entityDescriptor: String {
        return "\(Entity.classForCoder())"
    }

    private var fetchRequest: NSFetchRequest<Entity> {
        let name = String(describing: Entity.self)
        return NSFetchRequest<Entity>(entityName: name)
    }

    private func predicateFetchRequest(withIdentifier identifier: Entity.KeyType, excludingObjectID: NSManagedObjectID? = nil) -> NSFetchRequest<Entity> {
        let request = fetchRequest
        if let objectIDToExclude = excludingObjectID {
            request.predicate = NSPredicate(format: "\(Entity.keyName) == %@ && objectID != %@", argumentArray: [identifier, objectIDToExclude])
        } else {
            request.predicate = NSPredicate(format: "\(Entity.keyName) == %@", argumentArray: [identifier])
        }
        return request
    }

    // MARK: Protocol

    var context: NSManagedObjectContext {
        return coreDataStack.context
    }

    func retrieveAll() throws -> [CoreDataStore<Entity>.StoredType] {
        do {
            return try context.fetch(fetchRequest)
        } catch {
            throw CoreDataStoreError.coreDataError(error)
        }
    }

    func retrieveEntity(withIdentifier identifier: Entity.KeyType) throws -> Entity? {
        do {
            let results = try context.fetch(predicateFetchRequest(withIdentifier: identifier))
            return results.first
        } catch {
            throw CoreDataStoreError.coreDataError(error)
        }
    }

    func store(_ entity: Entity) throws {
        context.insert(entity)
        try save()
    }

    func store(_ entities: [Entity]) throws {
        entities.forEach(context.insert)
        try save()
    }

    func updateEntity(withIdentifier identifier: Entity.KeyType, updates: (Entity) -> ()) throws {
        guard let entity = try retrieveEntity(withIdentifier: identifier) else { return }
        updates(entity)
        try save()
    }

    func updateEntity(withIdentifier identifier: Entity.KeyType, byReplacingWith replacement: Entity) throws {
        assert(replacement.keyValue == identifier)
        do {
            // Not using self.delete(_:) in order to undo the delete operation if the store operation fails
            let fetched = try context.fetch(predicateFetchRequest(withIdentifier: identifier, excludingObjectID: replacement.objectID))
            if let entity = fetched.first {
                context.delete(entity)
            }
            try store(replacement)
        } catch {
            context.undo()
            throw error
        }
    }

    func deleteEntity(withIdentifier identifier: Entity.KeyType) throws {
        if let entity = try retrieveEntity(withIdentifier: identifier) {
            try delete(entity)
        }
    }

    func delete(_ entity: Entity) throws {
        context.delete(entity)
        try save()
    }

    func delete(_ entities: [Entity]) throws {
        entities.forEach(context.delete)
        try save()
    }

    func deleteAll() throws {
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            try context.execute(deleteRequest)
            try save()
        } catch {
            switch error {
            case CoreDataStoreError.coreDataError: throw error
            default: throw CoreDataStoreError.coreDataError(error)
            }
        }
    }

    func save() throws {
        do {
            try context.save()
        } catch {
            throw CoreDataStoreError.coreDataError(error)
        }
    }
}
