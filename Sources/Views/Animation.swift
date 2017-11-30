//
//  Animation.swift
//  DWM
//
//  Created by Clay Ellis on 11/28/17.
//  Copyright © 2017 Test. All rights reserved.
//
//  Inspired by: https://github.com/JohnSundell/Animate
//

import UIKit

struct Animation {
    let duration: TimeInterval
    let options: UIViewAnimationOptions?
    let closure: (UIView) -> Void

    init(duration: TimeInterval,
         options: UIViewAnimationOptions? = [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
         closure: @escaping (UIView) -> Void) {
        self.duration = duration
        self.options = options
        self.closure = closure
    }
}

fileprivate enum AnimationMode {
    case inSequence
    case inParallel
}

extension Animation {
    static func fadeIn(duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: { $0.alpha = 1 })
    }

    static func fadeOut(duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: { $0.alpha = 0 })
    }

    static func resize(to size: CGSize, duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: { $0.bounds.size = size })
    }

    static func scale(by scalar: CGFloat, duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: { $0.transform = $0.transform.scaledBy(x: scalar, y: scalar) })
    }

    static func resetScale(duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: { $0.transform = .identity })
    }

    static func move(byX x: CGFloat, y: CGFloat, duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: {
            $0.center.x += x
            $0.center.y += y
        })
    }

    static func setBackgroundColor(to color: UIColor, duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: { $0.backgroundColor = color })
    }
}

extension UIView {
    /// Animate in sequence
    @discardableResult func animate(_ animations: [Animation]) -> AnimationToken {
        return AnimationToken(view: self, animations: animations, mode: .inSequence)
    }

    @discardableResult func animate(_ animations: Animation...) -> AnimationToken {
        return animate(animations)
    }

    /// Animate in parallel
    @discardableResult func animateInParallel(_ animations: [Animation]) -> AnimationToken {
        return AnimationToken(view: self, animations: animations, mode: .inParallel)
    }

    @discardableResult func animateInParallel(_ animations: Animation...) -> AnimationToken {
        return animateInParallel(animations)
    }
}

internal extension UIView {
    fileprivate func performAnimations(_ animations: [Animation], completionHandler: @escaping () -> Void) {
        guard !animations.isEmpty else {
            return
        }

        var animations = animations
        let animation = animations.removeFirst()

        UIView.animate(withDuration: animation.duration, animations: {
            animation.closure(self)
        }, completion: { _ in
            self.performAnimations(animations, completionHandler: completionHandler)
        })
    }

    fileprivate func performAnimationsInParallel(_ animations: [Animation], completionHandler: @escaping () -> Void) {
        guard !animations.isEmpty else {
            return
        }

        let animationCount = animations.count
        var completionCount = 0

        let animationCopletionHandler = {
            completionCount += 1

            if completionCount == animationCount {
                completionHandler()
            }
        }

        for animation in animations {
            UIView.animate(withDuration: animation.duration, animations: {
                animation.closure(self)
            }, completion: { _ in
                animationCopletionHandler()
            })
        }
    }
}

extension UIView {
    static func animate(_ tokens: [AnimationToken]) {
        guard !tokens.isEmpty else {
            return
        }

        var tokens = tokens
        let token = tokens.removeFirst()

        token.perform {
            animate(tokens)
        }
    }

    static func animate(_ tokens: AnimationToken...) {
        animate(tokens)
    }

    static func animateInParallel(_ tokens: [AnimationToken]) {
        for token in tokens {
            token.perform {}
        }
    }

    static func animateInParallel(_ tokens: AnimationToken...) {
        animateInParallel(tokens)
    }
}

final class AnimationToken {
    private let view: UIView
    private let animations: [Animation]
    private let mode: AnimationMode
    private var isValid = true

    fileprivate init(view: UIView, animations: [Animation], mode: AnimationMode) {
        self.view = view
        self.animations = animations
        self.mode = mode
    }

    deinit {
        perform {}
    }

    fileprivate func perform(completionHandler: @escaping () -> Void) {
        guard isValid else { return }

        isValid = false

        switch mode {
        case .inSequence:
            view.performAnimations(animations, completionHandler: completionHandler)
        case .inParallel:
            view.performAnimationsInParallel(animations, completionHandler: completionHandler)
        }
    }
}
