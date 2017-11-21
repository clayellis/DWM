//
//  CenteredPreviewFlowLayout.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

class CenteredPreviewFlowLayout: UICollectionViewFlowLayout {

    private var mostRecentOffset: CGPoint = .zero

    private func fallback(usingProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        return mostRecentOffset
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
//        if velocity.x == 0 {
//            return mostRecentOffset
//        }
//
//        guard let collectionView = collectionView else {
//            return fallback(usingProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
//        }
//
//        let bounds = collectionView.bounds
//        let halfWidth = bounds.width * 0.5
//
//        guard let visibleCellAttributes = layoutAttributesForElements(in: bounds) else {
//            return fallback(usingProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
//        }
//
//        var candidateAttributes: UICollectionViewLayoutAttributes?
//        for attributes in visibleCellAttributes where attributes.representedElementCategory == UICollectionElementCategory.cell {
//            if attributes.center.x == 0 { continue }
//            if attributes.center.x > collectionView.contentOffset.x + halfWidth && velocity.x < 0 { continue }
//            candidateAttributes = attributes
//        }
//
//        if proposedContentOffset.x == -collectionView.contentInset.left {
//            return proposedContentOffset
//        }
//
//        guard let candidate = candidateAttributes else {
//            return mostRecentOffset
//        }
//
//        mostRecentOffset = CGPoint(x: floor(candidate.center.x - halfWidth), y: proposedContentOffset.y)
//        return mostRecentOffset
    }

    func prepareForCentering(in view: UIView) {
        guard let collectionView = collectionView else { return }
        var insets = collectionView.contentInset
        let inset = view.bounds.width - itemSize.width * 0.5
        insets.left = inset
        insets.right = inset
        collectionView.contentInset = insets
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
}


//if let cv = self.collectionView {
//
//    let cvBounds = cv.bounds
//    let halfWidth = cvBounds.size.width * 0.5;
//
//
//    if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
//
//        var candidateAttributes : UICollectionViewLayoutAttributes?
//        for attributes in attributesForVisibleCells {
//
//            // == Skip comparison with non-cell items (headers and footers) == //
//            if attributes.representedElementCategory != UICollectionElementCategory.cell {
//                continue
//            }
//
//            if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
//                continue
//            }
//            candidateAttributes = attributes
//        }
//
//        // Beautification step , I don't know why it works!
//        if(proposedContentOffset.x == -(cv.contentInset.left)) {
//            return proposedContentOffset
//        }
//
//        guard let _ = candidateAttributes else {
//            return mostRecentOffset
//        }
//        mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
//        return mostRecentOffset
//
//    }
//}

