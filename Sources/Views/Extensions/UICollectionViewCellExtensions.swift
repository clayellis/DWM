//
//  UICollectionViewCellExtensions.swift
//  DWM
//
//  Created by Clay Ellis on 11/26/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
