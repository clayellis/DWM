//
//  InstanceHashable.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//
//  Inspired by: https://github.com/JohnSundell/ImagineEngine/blob/master/Sources/Core/API/InstanceHashable.swift
//

import Foundation

/// Protocol adopted by objects that have their hash value calculated
/// based on their instance (object) identifier
protocol InstanceHashable: class, Hashable {}

extension InstanceHashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}
