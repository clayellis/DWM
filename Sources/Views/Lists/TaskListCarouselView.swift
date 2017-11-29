//
//  TaskListCarouselView.swift
//  DWM
//
//  Created by Clay Ellis on 11/17/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

protocol TaskListCarouselViewProtocol: class {
    var collectionViewLayout: CarouselFlowLayout { get }
    var collectionView: CarouselCollectionView { get }
}

class TaskListCarouselView: UIView, TaskListCarouselViewProtocol {

    let theme: ThemeProtocol
    let collectionViewLayout = CarouselFlowLayout()
    private(set) lazy var collectionView: CarouselCollectionView = {
        return CarouselCollectionView(frame: .zero, carouselLayout: collectionViewLayout)
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
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset.top = 10
        collectionViewLayout.pageScale = 0.9
        collectionViewLayout.previewScale = 0.5
        collectionView.backgroundColor = UIColor(hexString: "F4F4F4")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }

    private func configureLayout() {
        addAutoLayoutSubview(collectionView)
        collectionView.fillSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionViewLayout.prepareForCentering()
    }
}
