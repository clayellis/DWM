//
//  Utilities.swift
//  DWM
//
//  Created by Clay Ellis on 11/11/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

extension DateFormatter {
    public convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}

func measure(_ closure: () -> Void) {
    let start = Date()
    closure()
    let delta = Date().timeIntervalSince(start)
    print("Time Elapsed: \(delta)")
}
