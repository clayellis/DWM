//
//  Theme.swift
//  DWM
//
//  Created by Clay Ellis on 11/26/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

protocol ThemeProtocol {
    // Colors
    var primaryBackgroundColor: UIColor { get }
    var secondaryBackgroundColor: UIColor { get }
    var selectionHighlightColor: UIColor { get }
    var primaryTintColor: UIColor { get }
    var primaryTintHighlightColor: UIColor { get }
    var secondaryTintColor: UIColor { get }
    var secondaryTintHighlightColor: UIColor { get }

    // Fonts

}

final class DefaultTheme: ThemeProtocol {
    var primaryBackgroundColor: UIColor {
        return .white
    }

    var secondaryBackgroundColor: UIColor {
        return UIColor(hexString: "FBFBFB")
    }

    var selectionHighlightColor: UIColor {
        return UIColor(hexString: "F4F4F4")
    }

    var primaryTintColor: UIColor {
        return .black
    }

    var primaryTintHighlightColor: UIColor {
        return UIColor(hexString: "DEDEDE")
    }

    var secondaryTintColor: UIColor {
        return UIColor(hexString: "CCCCCC")
    }

    var secondaryTintHighlightColor: UIColor {
        return UIColor(hexString: "DEDEDE")
    }
}

struct Themes {
    static let `default`: ThemeProtocol = DefaultTheme()
}

// TODO: There needs to be a better strategy for injecting a theme into a view.
// Injection can't always be done on init
// So we rely on a property
// But that property won't be guaranteed to be there, so how we style views until it's set?
// And how do we re-style views once it's been set (since the views could be stateful)?
protocol ThemedView {
    var theme: ThemeProtocol { get set }
    func apply(_ theme: ThemeProtocol)
}
