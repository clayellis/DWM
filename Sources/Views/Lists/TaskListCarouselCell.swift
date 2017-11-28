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
    private let embededViewContainer = UIView()

    var embdedView: UIView? = nil {
        willSet {
            if let view = newValue {
                embededViewContainer.addAutoLayoutSubview(view)
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

        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowRadius = 14
        layer.shadowOpacity = 0.22
        layer.shadowColor = UIColor.black.cgColor

        bufferView.backgroundColor = .white
        embededViewContainer.backgroundColor = .white
    }

    func configureLayout() {
        contentView.addAutoLayoutSubview(bufferView)
        contentView.addAutoLayoutSubview(embededViewContainer)
        NSLayoutConstraint.activate([
            bufferView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bufferView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            bufferView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bufferView.heightAnchor.constraint(equalToConstant: 30),

            embededViewContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            embededViewContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            embededViewContainer.topAnchor.constraint(equalTo: bufferView.bottomAnchor),
            embededViewContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        embdedView = nil
    }
}
