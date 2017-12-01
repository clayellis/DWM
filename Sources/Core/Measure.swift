//
//  Measure.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

/// Measures the execution time of a unit of code.
/// - parameter printResult: Whether the result should be printed (format: `"Time Elapsed: _"`).
/// - parameter unit: The unit of code to be measured.
/// - returns: The `TimeInterval` elapsed during execution.
@discardableResult func measure(andPrintResult printResult: Bool = true, unit: () -> Void) -> TimeInterval {
    let start = Date()
    unit()
    let delta = Date().timeIntervalSince(start)
    if printResult {
        print("Time Elapsed: \(delta)")
    }
    return delta
}
