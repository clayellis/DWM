//
//  CoreDataStack.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import CoreData

public protocol CoreDataStackProtocol {
    /// The main context
    var context: NSManagedObjectContext { get }
}

final class CoreDataStack: CoreDataStackProtocol {
    private let managedObjectModel: NSManagedObjectModel
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    let context: NSManagedObjectContext

    enum CoreDataStackError: Error {
        case invalidModelLocation(ModelLocation)
        case invalidStoreLocation(StoreLocation)
    }

    enum ModelLocation {
        case url(URL)
        case bundles([Bundle])
    }

    enum StoreLocation {
        case url(URL)
    }

    init(modelLocation: ModelLocation, storeLocation: StoreLocation) throws {
        switch modelLocation {
        case .url(let url):
            guard let model = NSManagedObjectModel(contentsOf: url) else {
                throw CoreDataStackError.invalidModelLocation(modelLocation)
            }

            managedObjectModel = model

        case .bundles(let bundles):
            guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
                throw CoreDataStackError.invalidModelLocation(modelLocation)
            }

            managedObjectModel = model
        }

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        do {
            switch storeLocation {
            case .url(let url):
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
            }
        } catch {
            throw CoreDataStackError.invalidStoreLocation(storeLocation)
        }

        persistentStoreCoordinator = coordinator
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
    }
}
