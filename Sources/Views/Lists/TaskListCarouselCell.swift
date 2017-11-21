//
//  TaskListCarouselCell.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

class TaskListCarouselCell: UICollectionViewCell {

    var embdedView: UIView? = nil {
        willSet {
            if let view = newValue {
                contentView.addAutoLayoutSubview(view)
                view.fillSuperview()
            } else {
                embdedView?.removeFromSuperview()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureSubviews() {
        contentView.backgroundColor = .lightGray
        contentView.layer.cornerRadius = 32
        contentView.clipsToBounds = true
    }

    func configureLayout() {

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        embdedView = nil
    }
}
