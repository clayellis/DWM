//
//  FadeView.swift
//  DWM
//
//  Created by Clay Ellis on 11/30/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

class FadeView: UIView {
    enum Direction {
        case up
        case down
    }

    var color: UIColor = .white {
        didSet {
            configureFade()
        }
    }

    private(set) var direction: Direction

    private let gradient = CAGradientLayer()

    init(direction: Direction) {
        self.direction = direction
        super.init(frame: .zero)
        backgroundColor = .clear
        layer.addSublayer(gradient)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureFade()
    }

    private func configureFade() {
        gradient.frame = bounds
        gradient.colors = [UIColor.white.withAlphaComponent(0.0).cgColor, color.cgColor]
        switch direction {
        case .up:
            gradient.locations = [0.0, 0.5]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        case .down:
            gradient.locations = [0.0, 0.5]
            gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        }
    }
}
