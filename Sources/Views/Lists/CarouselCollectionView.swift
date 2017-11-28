//
//  CarouselCollectionView.swift
//  DWM
//
//  Created by Clay Ellis on 11/28/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

/// Delegate for `CarouselCollectionView`
protocol CarouselCollectionViewDelegate: class {
    /// Called whenever the `collectionView` changes pages
    /// - parameter collectionView: The `collectionView`
    /// - parameter page: The new page index
    func collectionView(_ collectionView: CarouselCollectionView, didChangePagesTo page: Int)
}

/// A `UICollectionView` subclass which provides a `currentPage` and a `pagingDelegate` to receive page change events
class CarouselCollectionView: UICollectionView {

    // MARK: Public

    weak var pagingDelegate: CarouselCollectionViewDelegate?

    var carouselLayout: CarouselFlowLayout {
        return collectionViewLayout as! CarouselFlowLayout
    }

    private(set) var currentPage: Int = 0 {
        didSet {
            if currentPage != oldValue {
                pagingDelegate?.collectionView(self, didChangePagesTo: currentPage)
            }
        }
    }

    // MARK: Init

    init(frame: CGRect, carouselLayout layout: CarouselFlowLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Observation

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset", isDragging else { return }
        currentPage = carouselLayout.currentPage
    }
}
