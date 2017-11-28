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
    var collectionView: CenteredPreviewCollectionView { get }
}

class TaskListCarouselView: UIView, TaskListCarouselViewProtocol {

    let theme: ThemeProtocol
    let collectionViewLayout = CenteredPreviewFlowLayout()
    private(set) lazy var collectionView: CenteredPreviewCollectionView = {
        return CenteredPreviewCollectionView(frame: .zero, centeredPreviewLayout: collectionViewLayout)
    }()

    init(factory: ThemeFactory) {
        theme = factory.makeTheme()
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
        collectionViewLayout.pageScale = 0.9
        collectionViewLayout.previewScale = 0.5
        collectionView.backgroundColor = .white
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
