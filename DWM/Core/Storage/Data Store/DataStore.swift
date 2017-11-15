//
//  DataStore.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

protocol DataStoreProtocol {
    associatedtype StoredType: Retrievable
    associatedtype KeyType

    /// Returns all stored entities of type `StoredType`
    func retrieveAll() throws -> [StoredType]

    /// Retrieves and returns the entity with the specified `identifier`
    func retrieveEntity(withIdentifier identifier: KeyType) throws -> StoredType?

    /// Stores an `entity` and saves
    func store(_ entity: StoredType) throws

    /// Stores a collection of entities and saves
    func store(_ entities: [StoredType]) throws

    /// Updates an entity with an identifier through an `updates` closure and saves updates
    func updateEntity(withIdentifier identifier: KeyType, updates: (StoredType) -> ()) throws

    /// Updates an entity with an identifier by replacing it and saves
    /// - Precondition: `replacement`'s keyValue must equal `identifier`
    func updateEntity(withIdentifier identifier: KeyType, byReplacingWith replacement: StoredType) throws

    /// Deletes the entity with the specified `identifier` if it exists and saves
    func deleteEntity(withIdentifier identifier: KeyType) throws

    /// Deletes the entity if it exists and saves
    func delete(_ entity: StoredType) throws

    /// Deletes the entities if they exist and saves
    func delete(_ entities: [StoredType]) throws

    /// Deletes all entities of type `StoredType` and saves
    func deleteAll() throws

    /// Saves the store to disk
    func save() throws
}
