//
//  Weak.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

class Weak<T> {
    private weak var _value: AnyObject?

    var value: T? {
        get {
            return _value as? T
        }
        set {
            _value = newValue as AnyObject
        }
    }

    init(value: T) {
        self.value = value
    }
}
