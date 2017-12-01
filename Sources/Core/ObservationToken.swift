//
//  ObservationToken.swift
//  DWM
//
//  Created by Clay Ellis on 12/1/17.
//  Copyright © 2017 Test. All rights reserved.
//
//  Inspired by: https://github.com/JohnSundell/ImagineEngine/blob/master/Sources/Core/API/EventToken.swift
//

import Foundation

/// Token that can be used to cancel an observation
class ObservationToken: CancellationToken {
    let identifier = UUID()
}
