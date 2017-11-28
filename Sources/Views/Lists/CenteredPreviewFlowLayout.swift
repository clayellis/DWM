//
//  CenteredPreviewFlowLayout.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

/// A `UICollectionViewFlowLayout` subclass which manually manages `sectionInset`s, `minimumLineSpacing`, and `itemSize`
/// in order to center items horizontally leaving a portion of the left and right items visible.
/// - Note: To customize behavior, see: `pageScale` and `previewScale`.
class CenteredPreviewFlowLayout: UICollectionViewFlowLayout {

    // MARK: - Public

    /// The calculated width (in points) of each page
    var pageWidth: CGFloat {
        return collectionViewWidth * pageScale
    }

    /// The desired width of the pages expressed as a percentage.
    /// Valid values are greater than `0` and less than or equal to `1.0`.
    /// A `pageScale` of `1.0` will fill the full width of the collection view.
    var pageScale: CGFloat = 0.75

    /// The desired amount of the gutters which will be used to preview the previous and following page.
    /// Valid values are greater than `0` and less than or equal to `1.0`.
    /// A `previewScale` of `0.5` use half of the gutter to display the previous and following page,
    /// while the remaing percentage of the gutter will be the space between pages.
    var previewScale: CGFloat = 0.5

    /// Call this method to automatically update `minimumLineSpacing`, `sectionInset.left`,
    /// `sectionInset.right`, and `itemSize`.
    func prepareForCentering(in view: UIView) {
        let previewWidth = gutterWidth * previewScale
        let spacing = gutterWidth - previewWidth
        minimumLineSpacing = spacing
        sectionInset.left = gutterWidth
        sectionInset.right = gutterWidth
        let itemHeight = collectionViewHeight - sectionInset.vertical
        itemSize = CGSize(width: pageWidth, height: itemHeight)
    }

    var currentPage: Int {
        guard let collectionView = collectionView else { return 0 }
        return calculateCurrentPage(using: collectionView.contentOffset)
    }

    // MARK: - Private

    private var collectionViewWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.frame.width
    }

    private var collectionViewHeight: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.frame.height
    }

    private var gutterWidth: CGFloat {
        return (collectionViewWidth - pageWidth) / 2
    }

    private func calculateCurrentPage(using contentOffset: CGPoint) -> Int {
        guard collectionViewWidth > 0 else { return 0 }
        return Int(floor((contentOffset.x + collectionViewWidth / 2) / collectionViewWidth))
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // FIXME: If you flick quickly, but over a very short distance, the collection view will jump
        // I tried fixing it by inspecting the velocity and manually adjusting the pageNumber, that didn't work
        let pageNumber = CGFloat(calculateCurrentPage(using: proposedContentOffset))
//        print(velocity.x)
//        if abs(velocity.x) > 0.5 {
//            if velocity.x < 0 {
//                pageNumber -= 1
//            } else {
//                pageNumber += 1
//            }
//        }
        let offsetX = pageNumber * (pageWidth + gutterWidth / 2)
        return CGPoint(x: offsetX, y: proposedContentOffset.y)
    }
}
