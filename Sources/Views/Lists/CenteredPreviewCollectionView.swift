//
//  CenteredPreviewCollectionView.swift
//  DWM
//
//  Created by Clay Ellis on 11/28/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

/// Delegate for `CenteredPreviewCollectionView`
protocol CenteredPreviewCollectionViewDelegate: class {
    /// Called whenever the `collectionView` changes pages
    /// - parameter collectionView: The `collectionView`
    /// - parameter page: The new page index
    func collectionView(_ collectionView: CenteredPreviewCollectionView, didChangePagesTo page: Int)
}

/// A `UICollectionView` subclass which provides a `currentPage` and a `pagingDelegate` to receive page change events
class CenteredPreviewCollectionView: UICollectionView {

    // MARK: Public

    weak var pagingDelegate: CenteredPreviewCollectionViewDelegate?

    var centeredPreviewLayout: CenteredPreviewFlowLayout {
        return collectionViewLayout as! CenteredPreviewFlowLayout
    }

    private(set) var currentPage: Int = 0 {
        didSet {
            if currentPage != oldValue {
                pagingDelegate?.collectionView(self, didChangePagesTo: currentPage)
            }
        }
    }

    // MARK: Init

    init(frame: CGRect, centeredPreviewLayout layout: CenteredPreviewFlowLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Observation

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else { return }
        currentPage = centeredPreviewLayout.currentPage
    }
}
