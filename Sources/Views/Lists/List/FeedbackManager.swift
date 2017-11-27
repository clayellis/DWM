//
//  FeedbackManager.swift
//  DWM
//
//  Created by Clay Ellis on 11/27/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

protocol FeedbackManagerProtocol {
    func triggerCompletionTouchDownFeedback()
    func cancelCompletionTouchDownFeedback()
    func triggerCompletionTouchUpFeedback()
    func triggerListChangeFeedback()
}

class FeedbackManager: FeedbackManagerProtocol {
    private lazy var queue: DispatchQueue = .main
    private var completionTouchDownItem: DispatchWorkItem?
    private var completionTouchDownTime: Date?

    func triggerCompletionTouchDownFeedback() {
        completionTouchDownTime = Date()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        completionTouchDownItem = DispatchWorkItem {
            generator.impactOccurred()
            self.completionTouchDownItem?.cancel()
            self.completionTouchDownItem = nil
        }
        queue.asyncAfter(deadline: .now() + 0.05, execute: completionTouchDownItem!)
    }

    func cancelCompletionTouchDownFeedback() {
        completionTouchDownItem?.cancel()
        completionTouchDownItem = nil
        completionTouchDownTime = nil
    }

    func triggerCompletionTouchUpFeedback() {
        var impactStyle = UIImpactFeedbackStyle.medium
        if let time = completionTouchDownTime {
            let delta = Date().timeIntervalSince(time)
            if delta > 0.5 {
                impactStyle = .heavy
            } else if delta > 0.2 {
                impactStyle = .medium
            } else {
                impactStyle = .light
            }
            completionTouchDownTime = nil
        }

        if let item = completionTouchDownItem {
            item.perform()
            item.cancel()
        }

        // Delay the touch up slightly so that both are felt
        let generator = UIImpactFeedbackGenerator(style: impactStyle)
        generator.prepare()
        queue.asyncAfter(deadline: .now() + 0.1) { generator.impactOccurred() }
    }

    func triggerListChangeFeedback() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
