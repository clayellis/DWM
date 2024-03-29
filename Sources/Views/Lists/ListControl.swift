//
//  ListControl.swift
//  DWM
//
//  Created by Clay Ellis on 11/26/17.
//  Copyright © 2017 Test. All rights reserved.
//

import UIKit

protocol ListControlDataSource: class {
    func numberOfLists() -> Int
    func listControl(_ listControl: ListControl, titleForListAt index: Int) -> String
    func listControl(_ listControl: ListControl, indicatorStyleForListAt index: Int) -> ListControlItem.IndicatorStyle?
    func listControlCurrentSelectedIndex(_ listControl: ListControl) -> Int?
}

protocol ListControlDelegate: class {
    func listControl(_ listControl: ListControl, didSelectListAt index: Int)
}

class ListControl: UIView {

    // MARK: Private Properties

    private let stackView = UIStackView()
    private var items = [ListControlItem]()

    // MARK: Public Properties

    weak var delegate: ListControlDelegate?
    weak var dataSource: ListControlDataSource? {
        didSet { reloadData() }
    }

    var selectedIndex: Int? {
        didSet { updateSelection(from: oldValue, to: selectedIndex) }
    }

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureLayout()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private func configureSubviews() {
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 15
    }

    private func configureLayout() {
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        addAutoLayoutSubview(stackView)
        stackView.fillSuperviewLayoutMargins()
    }

    func reloadData() {
        /*
         Measurements:

         Time Elapsed: 0.0374810099601746
         Time Elapsed: 0.038686990737915

         */

        guard let dataSource = dataSource else { return }

        selectedIndex = nil

        for item in items {
            item.removeFromSuperview()
            stackView.removeArrangedSubview(item)
        }

        items = []

        for index in 0 ..< dataSource.numberOfLists() {
            let item = ListControlItem()
            let itemTitle = dataSource.listControl(self, titleForListAt: index)
            let indicatorStyle = dataSource.listControl(self, indicatorStyleForListAt: index)
            item.tag = index
            item.setTitle(itemTitle, for: .normal)
            item.setIndicator(style: indicatorStyle)
            item.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            items.append(item)
            stackView.addArrangedSubview(item)
        }

        selectedIndex = dataSource.listControlCurrentSelectedIndex(self)
    }

    private func updateSelection(from oldIndex: Int?, to newIndex: Int?) {
        guard newIndex != oldIndex else { return }
        let duration: TimeInterval = 0.1
        let options: UIViewAnimationOptions = [.beginFromCurrentState, .allowUserInteraction, .transitionCrossDissolve]
        if let old = oldIndex {
            let item = items[old]
            UIView.transition(with: item, duration: duration, options: options, animations: {
                item.isSelected = false
            }, completion: nil)
        }

        if let new = newIndex {
            let item = items[new]
            UIView.transition(with: item, duration: duration, options: options, animations: {
                item.isSelected = true
            }, completion: nil)
        }
    }

    @objc private func itemTapped(_ item: ListControlItem) {
        let index = item.tag
        selectedIndex = index
        delegate?.listControl(self, didSelectListAt: index)
    }
}

class ListControlItem: UIButton {

    struct IndicatorImageContext {
        let normalImageName: String
        let normalHighlightedImageName: String
        let selectedImageName: String
        let selectedHighlightedImageName: String
    }

    enum IndicatorStyle {
        case image(IndicatorImageContext)
        case text(String)
    }

    struct Sizes {
        // TODO: Find a way to make these height constants dynamic based on preferredFontSize
        static let height: CGFloat = 35
        static let indicatorHeight: CGFloat = 18
        static var cornerRadius: CGFloat {
            return height / 2
        }
    }

    init() {
        super.init(frame: .zero)
        // Normal
        setTitleColor(.black, for: .normal)
        setBackgroundColor(.clear, forUIControlState: .normal)
        // Normal Highlighted
        setTitleColor(UIColor.white, for: [.normal, .highlighted])
        setBackgroundColor(UIColor.black.withAlphaComponent(0.1), forUIControlState: [.normal, .highlighted])
        // Selected
        setTitleColor(.white, for: .selected)
        setBackgroundColor(.black, forUIControlState: .selected)
        // Selected Highlighted
        setTitleColor(UIColor.white.withAlphaComponent(0.5), for: [.selected, .highlighted])
        setBackgroundColor(UIColor.black.withAlphaComponent(0.8), forUIControlState: [.selected, .highlighted])

        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        layer.cornerRadius = Sizes.cornerRadius
        clipsToBounds = true

        contentEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        heightAnchor.constraint(equalToConstant: Sizes.height, priority: .defaultHigh).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setIndicator(style: IndicatorStyle?) {
        // FIXME: There is a slight flat edge on the right side of the text indicator circle image
        // The flat edge appears on images (CheckWhiteCircle) too which leads me to believe that it's caused by the image/titleEdgeInsets
        let controlStates: [UIControlState] = [.normal, [.normal, .highlighted], .selected, [.selected, .highlighted]]
        if let style = style {
            switch style {
            case .text(let text):
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label.text = text
                label.textAlignment = .center
                let proposedSize = label.intrinsicContentSize
                label.layer.masksToBounds = true
                label.layer.cornerRadius = proposedSize.height / 2

                label.bounds.size.height = Sizes.indicatorHeight

                if proposedSize.height > proposedSize.width {
                    label.bounds.size.width = label.bounds.size.height
                } else {
                    let insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
                    label.bounds.size.width = proposedSize.width + insets.horizontal
                }

                // FIXME: This seems to be a very intense set of operations that could be made more efficient
                // - by storing the backgroundColor for states in a local variable or in a function
                //      - so that it doesn't have to be determined by inspecting the image data
                // - by potentially adding the label as a subview and adjusting colors manually
                //      - so that an image doesn't have to be created from the label and set

                /* Measurements:

                 Time Elapsed: 0.00205498933792114
                 Time Elapsed: 0.000539958477020264

                 Time Elapsed: 0.00198900699615479
                 Time Elapsed: 0.000523030757904053

                 Time Elapsed: 0.00181597471237183
                 Time Elapsed: 0.000452995300292969

                */

                // After doing some measurements, this might not actually be *that* slow
                // Though it could be sped up by doing some of the things listed above

                for controlState in controlStates {
                    if controlState == .normal {
                        let inverseState: UIControlState = .selected
                        label.textColor = titleColor(for: inverseState)
                        label.backgroundColor = backgroundColor(for: inverseState)
                    } else if controlState == [.normal, .highlighted] {
                        let inverseState: UIControlState = [.selected, .highlighted]
                        label.textColor = titleColor(for: inverseState)
                        label.backgroundColor = backgroundColor(for: inverseState)
                    } else {
                        label.textColor = titleColor(for: controlState)
                        label.backgroundColor = .clear
                    }
                    setImage(UIImage(label: label, sizeByContent: false), for: controlState)
                }

            case .image(let imageContext):
                setImage(UIImage(named: imageContext.normalImageName), for: .normal)
                setImage(UIImage(named: imageContext.normalHighlightedImageName), for: [.normal, .highlighted])
                setImage(UIImage(named: imageContext.selectedImageName), for: .selected)
                setImage(UIImage(named: imageContext.selectedHighlightedImageName), for: [.selected, .highlighted])
                imageView?.contentMode = .scaleAspectFit
                imageView?.bounds.size = CGSize(width: Sizes.indicatorHeight, height: Sizes.indicatorHeight)
                adjustsImageWhenHighlighted = false
            }
            setImageTitleSpacing(2)
        } else {
            for controlState in controlStates {
                setImage(nil, for: controlState)
            }
            setImageTitleSpacing(0)
        }
    }
}
