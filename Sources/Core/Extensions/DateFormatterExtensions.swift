//
//  DateFormatterExtensions.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//

import Foundation

extension DateFormatter {
    /// Initialize a `DateFormatter` with a `dateFormat` string.
    /// - parameter dateFormat: The date format string used by the receiver.
    public convenience init(format dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
