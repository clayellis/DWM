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
        guard let dataSource = dataSource else { return }

        for item in items {
            item.removeFromSuperview()
            stackView.removeArrangedSubview(item)
        }

        items = []

        for index in 0 ..< dataSource.numberOfLists() {
            let item = ListControlItem()
            let itemTitle = dataSource.listControl(self, titleForListAt: index)
            item.tag = index
            item.setTitle(itemTitle, for: .normal)
            item.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            items.append(item)
            stackView.addArrangedSubview(item)
        }

        if !items.isEmpty {
            selectedIndex = 0
        }
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

private class ListControlItem: UIButton {
    // TODO: Add a small label to the left of the title label to indicate the number of tasks left or a checkmark if the list is complete

    struct Sizes {
        static let height: CGFloat = 35
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
        setTitleColor(UIColor.black.withAlphaComponent(0.5), for: [.normal, .highlighted])
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
}
