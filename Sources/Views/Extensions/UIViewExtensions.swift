//
//  UIViewExtensions.swift
//  DWM
//
//  Created by Clay Ellis on 11/17/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

// MARK: - NSLayoutConstraint Convenience Methods

extension UIView {
    public func addAutoLayoutSubview(_ subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
    }

    public func addAutoLayoutSubviews(_ subviews: UIView...) {
        subviews.forEach(addAutoLayoutSubview)
    }

    public func insertAutoLayoutSubview(_ view: UIView, at index: Int) {
        insertSubview(view, at: index)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    public func insertAutoLayoutSubview(_ view: UIView, belowSubview: UIView) {
        insertSubview(view, belowSubview: belowSubview)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    public func insertAutoLayoutSubview(_ view: UIView, aboveSubview: UIView) {
        insertSubview(view, aboveSubview: aboveSubview)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    public func exchangeSubview(_ subviewOne: UIView, with subviewTwo: UIView) {
        if let subviewOneIndex = indexOfSubview(subviewOne),
            let subviewTwoIndex = indexOfSubview(subviewTwo) {
            self.exchangeSubview(at: subviewOneIndex, withSubviewAt: subviewTwoIndex)
        }
    }
}

// MARK: - Layout Macros

extension UIView {
    public func activate(_ constraints: NSLayoutConstraint...) {
        NSLayoutConstraint.activate(constraints)
    }

    public func fillSuperview(priority p: UILayoutPriority = .required) {
        guard let superview = self.superview else { return }
        activate(
            leftAnchor.constraint(equalTo: superview.leftAnchor, priority: p),
            rightAnchor.constraint(equalTo: superview.rightAnchor, priority: p),
            topAnchor.constraint(equalTo: superview.topAnchor, priority: p),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, priority: p)
        )
    }

    @discardableResult
    public func fillSuperviewLayoutMargins(priority p: UILayoutPriority = .required) -> (left: NSLayoutConstraint, right: NSLayoutConstraint, top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        guard let superview = self.superview else {
            fatalError("\(self) has not been added as a subview")
        }
        let left = leftAnchor.constraint(equalTo: superview.leftMargin, priority: p)
        let right = rightAnchor.constraint(equalTo: superview.rightMargin, priority: p)
        let top = topAnchor.constraint(equalTo: superview.topMargin, priority: p)
        let bottom = bottomAnchor.constraint(equalTo: superview.bottomMargin, priority: p)
        activate(left, right, top, bottom)
        return (left, right, top, bottom)
    }

    public func centerInSupervew(priority p: UILayoutPriority = .required) {
        guard let superview = self.superview else { return }
        activate(
            centerXAnchor.constraint(equalTo: superview.centerXAnchor, priority: p),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor, priority: p)
        )
    }

    public func centerInSupervewLayoutMargins(priority p: UILayoutPriority = .required) {
        guard let superview = self.superview else { return }
        activate(
            centerXAnchor.constraint(equalTo: superview.centerXMargin, priority: p),
            centerYAnchor.constraint(equalTo: superview.centerYMargin, priority: p)
        )
    }
}

// MARK: - Layout Margins Guide Shortcut

extension UIView {
    public var leftMargin: NSLayoutXAxisAnchor {
        return layoutMarginsGuide.leftAnchor
    }

    public var rightMargin: NSLayoutXAxisAnchor {
        return layoutMarginsGuide.rightAnchor
    }

    public var centerXMargin: NSLayoutXAxisAnchor {
        return layoutMarginsGuide.centerXAnchor
    }

    public var widthMargin: NSLayoutDimension {
        return layoutMarginsGuide.widthAnchor
    }

    public var topMargin: NSLayoutYAxisAnchor {
        return layoutMarginsGuide.topAnchor
    }

    public var bottomMargin: NSLayoutYAxisAnchor {
        return layoutMarginsGuide.bottomAnchor
    }

    public var centerYMargin: NSLayoutYAxisAnchor {
        return layoutMarginsGuide.centerYAnchor
    }

    public var heightMargin: NSLayoutDimension {
        return layoutMarginsGuide.heightAnchor
    }
}

// MARK: - Subview Retrieval

extension UIView {
    public var allSubviews: [UIView] {
        var all = subviews
        for subview in all {
            all.append(contentsOf: subview.allSubviews)
        }
        return all
    }

    public func subviewWithClassName(_ className: String) -> UIView? {
        return allSubviews.first { type(of: $0).description() == className }
    }

    public func subviewsWithClassName(_ className: String) -> [UIView] {
        return allSubviews.filter { type(of: $0).description() == className }
    }

    public func subviewWithClassType<T>(_ classType: T.Type) -> T? {
        return allSubviews.first { $0 is T } as? T
    }

    public func subviewsWithClassType<T>(_ classType: T.Type) -> [T] {
        return allSubviews.map { $0 as? T }.flatMap { $0 }
    }

    public func indexOfSubview(_ subview: UIView) -> Int? {
        return subviews.index(of: subview)
    }

    public var currentFirstResponder: UIResponder? {
        if isFirstResponder {
            return self
        }

        for view in self.subviews {
            if let responder = view.currentFirstResponder {
                return responder
            }
        }

        return nil
    }

    // Useful, but commenting out to avoid warnings
    //    func printRecursiveDescription() {
    //        print(perform("recursiveDescription"))
    //    }
    //
    //    func printAutolayoutTrace() {
    //        print(perform("_autolayoutTrace"))
    //    }
}

// MARK: - UIStackView

public extension UIStackView {
    func addArrangedSubviews(_ subviews: UIView...) {
        subviews.forEach(addArrangedSubview)
    }
}

// MARK: - Animations

public extension UIView {
    public func shake(withDuration duration: TimeInterval = 0.6) {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        shake.duration = duration
        shake.values = [-12, 12, -12, 12, -6, 6, -3, 3, 0]
        layer.add(shake, forKey: "Shake")
    }

    public func flash(withDuration duration: TimeInterval = 0.6) {
        let flash = CAKeyframeAnimation(keyPath: "opacity")
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        flash.duration = duration
        flash.values = [1, 0, 1, 0, 1]
        layer.add(flash, forKey: "Flash")
    }
}

// MARK: - Constraint + Priority

// MARK: NSLayoutDimension + Float

public extension NSLayoutDimension {

    // Anchor

    public func constraint(equalTo anchor: NSLayoutDimension, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor)
        constraint.priority = p
        return constraint
    }

    // Constant

    public func constraint(equalToConstant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalToConstant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualToConstant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualToConstant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualToConstant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualToConstant: c)
        constraint.priority = p
        return constraint
    }

    // Anchor, Constant

    public func constraint(equalTo anchor: NSLayoutDimension, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }

    // Anchor, Multiplier

    public func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor, multiplier: m)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor, multiplier: m)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor, multiplier: m)
        constraint.priority = p
        return constraint
    }

    // Anchor, Multiplier, Constant

    public func constraint(equalTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor, multiplier: m, constant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor, multiplier: m, constant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualTo anchor: NSLayoutDimension, multiplier m: CGFloat, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor, multiplier: m, constant: c)
        constraint.priority = p
        return constraint
    }
}

// MARK: NSLayoutYAxisAnchor + Float

public extension NSLayoutYAxisAnchor {

    // Anchor

    public func constraint(equalTo anchor: NSLayoutYAxisAnchor, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor)
        constraint.priority = p
        return constraint
    }

    // Anchor, Constant

    public func constraint(equalTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualTo anchor: NSLayoutYAxisAnchor, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }
}

// MARK: NSLayoutXAxisAnchor + Float

public extension NSLayoutXAxisAnchor {

    // Anchor

    public func constraint(equalTo anchor: NSLayoutXAxisAnchor, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor)
        constraint.priority = p
        return constraint
    }

    // Anchor, Constant

    public func constraint(equalTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(lessThanOrEqualTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }

    public func constraint(greaterThanOrEqualTo anchor: NSLayoutXAxisAnchor, constant c: CGFloat, priority p: UILayoutPriority) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor, constant: c)
        constraint.priority = p
        return constraint
    }
}
