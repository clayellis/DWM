//
//  CoreDataStoreTests.swift
//  DWMTests
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//

import XCTest
@testable import DWM
import CoreData

class CoreDataStoreTests: XCTestCase {

    var entityDataStore: CoreDataStore<EntityData>!

    override func setUp() {
        super.setUp()
        let storeURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Test.sqlite")
        let stack = try! CoreDataStack(modelLocation: .bundles(Bundle.allBundles),
                                  storeLocation: .url(storeURL))
        entityDataStore = CoreDataStore(coreDataStack: stack)
    }

    override func tearDown() {
        super.tearDown()
        try? entityDataStore.deleteAll()
    }

    func testBeginsEmpty() {
        do {
            let result = try entityDataStore.retrieveAll()
            XCTAssertTrue(result.isEmpty)
        } catch {
            XCTFail()
        }
    }

    func testEntity() {
        let id = UUID()
        let value = "Hello"
        let entity = Entity(id: id, value: value)
        XCTAssertEqual(entity.id, id)
        XCTAssertEqual(entity.value, value)
    }

    func testStoreThenRetrieve() {
        do {
            let entity = Entity(id: UUID(), value: "Hello")
            let entityData = EntityData(from: entity, in: entityDataStore.context)
            try entityDataStore.store(entityData)
            guard let retrieved = try entityDataStore.retrieveEntity(withIdentifier: entity.id) else {
                XCTFail()
                return
            }
            XCTAssertEqual(retrieved.id, entity.id)
            XCTAssertEqual(retrieved.value, entity.value)
            let converted = try Entity(from: retrieved)
            XCTAssertEqual(converted, entity)
        } catch {
            XCTFail()
        }
    }

    func testUpdate() {
        do {
            let originalValue = "Hello"
            let updatedValue = "Updated"
            let entity = Entity(id: UUID(), value: originalValue)
            let entityData = EntityData(from: entity, in: entityDataStore.context)
            try entityDataStore.store(entityData)

            // Retrieve, Assert value
            guard let retrieved = try entityDataStore.retrieveEntity(withIdentifier: entity.id) else {
                XCTFail()
                return
            }
            XCTAssertEqual(retrieved.value, originalValue)

            // Update
            let updatedEntity = Entity(id: entity.id, value: updatedValue)
            let updatedEntityData = updatedEntity.prepareForStorage(in: entityDataStore.context)
            try entityDataStore.updateEntity(withIdentifier: entity.id, byReplacingWith: updatedEntityData)

            // Retrieve, Assert value
            guard let updatedRetrieved = try entityDataStore.retrieveEntity(withIdentifier: entity.id) else {
                XCTFail()
                return
            }
            XCTAssertEqual(updatedRetrieved.value, updatedValue)

        } catch {
            XCTFail()
        }
    }

    func testUpdateUsingClosure() {
        do {
            let originalValue = "Hello"
            let updatedValue = "Updated"
            let entity = Entity(id: UUID(), value: originalValue)
            let entityData = EntityData(from: entity, in: entityDataStore.context)
            try entityDataStore.store(entityData)

            // Retrieve, Assert value
            guard let retrieved = try entityDataStore.retrieveEntity(withIdentifier: entity.id) else {
                XCTFail()
                return
            }
            XCTAssertEqual(retrieved.value, originalValue)

            // Update
            try entityDataStore.updateEntity(withIdentifier: entity.id) { entity in
                entity.value = updatedValue
            }

            // Retrieve, Assert value
            guard let updatedRetrieved = try entityDataStore.retrieveEntity(withIdentifier: entity.id) else {
                XCTFail()
                return
            }
            XCTAssertEqual(updatedRetrieved.value, updatedValue)

        } catch {
            XCTFail()
        }
    }

    func testDeleteByIdentifier() {
        do {
            let entity = Entity(id: UUID(), value: "Hello")
            let entityData = EntityData(from: entity, in: entityDataStore.context)
            try entityDataStore.store(entityData)
            XCTAssertNotNil(try entityDataStore.retrieveEntity(withIdentifier: entity.id))
            try entityDataStore.deleteEntity(withIdentifier: entity.id)
            XCTAssertNil(try entityDataStore.retrieveEntity(withIdentifier: entity.id))
        } catch {
            XCTFail()
        }
    }

    func testDeleteByEntity() {
        do {
            let entity = Entity(id: UUID(), value: "Hello")
            let entityData = EntityData(from: entity, in: entityDataStore.context)
            try entityDataStore.store(entityData)
            let retrieved = try entityDataStore.retrieveEntity(withIdentifier: entity.id)
            XCTAssertNotNil(retrieved)
            try entityDataStore.delete(retrieved!)
            XCTAssertNil(try entityDataStore.retrieveEntity(withIdentifier: entity.id))
        } catch {
            XCTFail()
        }
    }

    func testStoreMultipleThenRetrieveAll() {
        do {
            let first = Entity(id: UUID(), value: "first")
            let second = Entity(id: UUID(), value: "second")
            let third = Entity(id: UUID(), value: "third")
            let data = [first, second, third].map { EntityData(from: $0, in: entityDataStore.context) }
            try entityDataStore.store(data)
            let result = try entityDataStore.retrieveAll()
            XCTAssert(result.count == 3)
            XCTAssert(result.contains(where: { $0.value == "first"}))
            XCTAssert(result.contains(where: { $0.value == "second"}))
            XCTAssert(result.contains(where: { $0.value == "third"}))
        } catch {
            XCTFail()
        }
    }

    func testDeleteMultiple() {
        do {
            let first = Entity(id: UUID(), value: "first")
            let second = Entity(id: UUID(), value: "second")
            let third = Entity(id: UUID(), value: "third")
            let data = [first, second, third].map { EntityData(from: $0, in: entityDataStore.context) }
            try entityDataStore.store(data)
            let results = try entityDataStore.retrieveAll()
            XCTAssert(results.count == 3)
            try entityDataStore.delete(results)
            XCTAssert(try entityDataStore.retrieveAll().count == 0)
        } catch {
            XCTFail()
        }
    }
}

// MARK: - Entity

public struct Entity {
    let id: UUID
    let value: String
}

extension Entity: CoreDataStorable {
    public typealias StoredType = EntityData

    public init(from storedObject: EntityData) throws {
        guard let id = storedObject.id else {
            throw CoreDataStorableError.storedObjectMissingValuesForProperties(["id"])
        }

        guard let value = storedObject.value else {
            throw CoreDataStorableError.storedObjectMissingValuesForProperties(["value"])
        }

        self.id = id
        self.value = value
    }

    public func prepareForStorage(in context: NSManagedObjectContext) -> EntityData {
        return EntityData(from: self, in: context)
    }
}

extension Entity: Equatable {
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.id == rhs.id
            && lhs.value == rhs.value
    }
}

// MARK: - Generated

@objc(EntityData)
public final class EntityData: NSManagedObject {

}

extension EntityData {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityData> {
        return NSFetchRequest<EntityData>(entityName: "EntityData")
    }

    @NSManaged public var value: String?
    @NSManaged public var id: UUID?
}

// MARK: - Retrievable

extension EntityData: Retrievable {
    public typealias KeyType = UUID

    public static var keyName: String { return "id" }
    public var keyValue: UUID { return id! }
}

extension EntityData: CoreDataConfigurable {
    public typealias ConfiguringType = Entity

    public convenience init(from configuringObject: Entity, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = configuringObject.id
        self.value = configuringObject.value
    }
}
