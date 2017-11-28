//
//  TaskListCarouselCell.swift
//  DWM
//
//  Created by Clay Ellis on 11/18/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

class TaskListCarouselCell: UICollectionViewCell {

    private let bufferView = UIView()
    private let embeddedViewGuide = UILayoutGuide()

    var embeddedView: UIView? = nil {
        willSet {
            if let view = newValue {
                contentView.addAutoLayoutSubview(view)
                view.fillLayoutGuide(embeddedViewGuide)
            } else {
                embeddedView?.removeFromSuperview()
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

        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 14
        layer.shadowOpacity = 0.22
        layer.shadowColor = UIColor.black.cgColor

        bufferView.backgroundColor = .white
    }

    func configureLayout() {
        contentView.addAutoLayoutSubview(bufferView)
        contentView.addLayoutGuide(embeddedViewGuide)
        NSLayoutConstraint.activate([
            bufferView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bufferView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            bufferView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bufferView.heightAnchor.constraint(equalToConstant: 30),

            embeddedViewGuide.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            embeddedViewGuide.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            embeddedViewGuide.topAnchor.constraint(equalTo: bufferView.bottomAnchor),
            embeddedViewGuide.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        embeddedView = nil
    }
}
