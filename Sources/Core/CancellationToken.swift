//
//  CancellationToken.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//
//  Inspired by: https://github.com/JohnSundell/ImagineEngine/blob/master/Sources/Core/API/CancellationToken.swift
//

import Foundation

/// Class used to cancel an operation that takes place over time
class CancellationToken: InstanceHashable {
    private(set) var isCancelled = false

    /// Cancel the operation that this token is for
    func cancel() {
        isCancelled = true
    }
}
