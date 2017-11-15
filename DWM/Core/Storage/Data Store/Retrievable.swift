//
//  Retrievable.swift
//  DWM
//
//  Created by Clay Ellis on 11/12/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

protocol Retrievable {
    associatedtype KeyType: Equatable

    static var keyName: String { get }
    var keyValue: KeyType { get }
}

// TODO: Create a protocol (chained from Retrievable) that ties the two types together
//  - init(fromStored stored: NS
