//
//  CoreDataStorable.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataStorableError: Error {
    case storedObjectMissingValuesForProperties([String])
}

protocol CoreDataStorable {
    associatedtype StoredType: NSManagedObject, CoreDataConfigurable

    init(from storedObject: StoredType) throws
    func prepareForStorage(in context: NSManagedObjectContext) -> StoredType
    func require(properties: [String]) throws
}

extension CoreDataStorable {
    func require(properties: [String]) throws {
        var missingProperties = [String]()
        let mirror = Mirror(reflecting: self)
        for (name, value) in mirror.children {
            guard let name = name, properties.contains(name) else { continue }
            if "\(value)" == "nil" {
                missingProperties.append("\(name)")
            }
        }
        if missingProperties.isEmpty { return }
        throw CoreDataStorableError.storedObjectMissingValuesForProperties(missingProperties)
    }
}

protocol CoreDataConfigurable {
    associatedtype ConfiguringType: CoreDataStorable

    init(from configuringObject: ConfiguringType, in context: NSManagedObjectContext)
}
