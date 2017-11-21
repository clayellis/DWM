//
//  TaskListCarouselView.swift
//  DWM
//
//  Created by Clay Ellis on 11/17/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

protocol TaskListCarouselViewProtocol: class {
    var collectionViewLayout: CenteredPreviewFlowLayout { get }
    var collectionView: UICollectionView { get }
}

class TaskListCarouselView: UIView, TaskListCarouselViewProtocol {

    let collectionViewLayout = CenteredPreviewFlowLayout()
    private(set) lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }()

    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        configureSubviews()
        configureLayout()
    }

    private func configureSubviews() {
        backgroundColor = .white
        collectionViewLayout.scrollDirection = .horizontal
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }

    private func configureLayout() {
        addAutoLayoutSubview(collectionView)
        collectionView.fillSuperviewSafeArea()
    }
}
