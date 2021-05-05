//
//  UITableView+Ex.swift
//  Base Extensions
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)

#if canImport(UIKit)
    import UIKit
#endif

public extension UITableView {
    func layoutSizeFittingHeaderView(_ width: CGFloat? = nil) {
        guard let viewFitting = self.tableHeaderView else { return }

        let fitWidth = width ?? self.frame.width

        viewFitting.translatesAutoresizingMaskIntoConstraints = false
        // [add subviews and their constraints to view]
        let widthConstraint = NSLayoutConstraint(item: viewFitting, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: fitWidth)
        widthConstraint.isActive = true

        viewFitting.addConstraint(widthConstraint)
        viewFitting.setNeedsLayout()
        viewFitting.layoutIfNeeded()
        let fittingHeight = viewFitting.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        viewFitting.removeConstraint(widthConstraint)
        widthConstraint.isActive = false

        viewFitting.frame = CGRect(x: 0, y: 0, width: fitWidth, height: fittingHeight)
        viewFitting.translatesAutoresizingMaskIntoConstraints = true

        self.tableHeaderView = viewFitting
    }

    func layoutSizeFittingFooterView(_ width: CGFloat? = nil) {
        guard let viewFitting = self.tableFooterView else { return }

        let fitWidth = width ?? self.frame.width

        viewFitting.translatesAutoresizingMaskIntoConstraints = false
        // [add subviews and their constraints to view]
        let widthConstraint = NSLayoutConstraint(item: viewFitting, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: fitWidth)
        widthConstraint.isActive = true

        viewFitting.addConstraint(widthConstraint)
        viewFitting.setNeedsLayout()
        viewFitting.layoutIfNeeded()
        let fittingHeight = viewFitting.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        viewFitting.removeConstraint(widthConstraint)
        widthConstraint.isActive = false

        viewFitting.frame = CGRect(x: 0, y: 0, width: fitWidth, height: fittingHeight)
        viewFitting.translatesAutoresizingMaskIntoConstraints = true

        self.tableFooterView = viewFitting
    }

    func setTableHeaderViewLayoutSizeFitting(_ headerView: UIView) {
        self.tableHeaderView = headerView
        self.layoutSizeFittingHeaderView()
    }

    func setTableFooterViewLayoutSizeFitting(_ footerView: UIView) {
        self.tableFooterView = footerView
        self.layoutSizeFittingFooterView()
    }

    func makeHeaderLeastNonzeroHeight() {
        let tempHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: CGFloat.leastNonzeroMagnitude))
        self.tableHeaderView = tempHeaderView
    }

    func makeFooterLeastNonzeroHeight() {
        let tempHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: CGFloat.leastNonzeroMagnitude))
        self.tableFooterView = tempHeaderView
    }

    func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.row >= 0 && indexPath.section >= 0 && indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }

    func scrollToLastRow(animated: Bool = true, atScrollPosition: UITableView.ScrollPosition = .bottom) {
        let section = self.numberOfSections - 1
        guard section >= 0 else { return }
        let row = self.numberOfRows(inSection: section) - 1
        guard row >= 0, self.isValidIndexPath(IndexPath(row: row, section: section)) else { return }

        self.scrollToRow(at: IndexPath(row: row, section: section), at: atScrollPosition, animated: animated)
    }

    func scrollToCell(_ toCell: UITableViewCell?, animated: Bool = true, atScrollPosition: UITableView.ScrollPosition = .bottom) {
        guard let cell = toCell else { return }
        guard let indexPath = self.indexPath(for: cell), self.isValidIndexPath(indexPath) else { return }

        self.scrollToRow(at: indexPath, at: atScrollPosition, animated: animated)
    }

    func isLastIndexPath(_ indexPath: IndexPath) -> Bool {
        return (indexPath.section == self.numberOfSections - 1) && (indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1)
    }

    func setSeparatorNoneForNoCells() {
        let footerV = UIView()
        footerV.backgroundColor = self.backgroundColor ?? UIColor.white
        self.tableFooterView = footerV
    }

    func reloadData(_ completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.reloadData()
        CATransaction.commit()
    }

    func reloadDataWithResetOffset() {
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.allowAnimatedContent, animations: { [weak self] in
            self?.contentOffset = CGPoint.zero
        }) { [weak self] (finish) in
            self?.reloadData()
        }
    }
    
    func register<T: UITableViewCell>(_ cell: T.Type) {
        register(cell, forCellReuseIdentifier: cell.reuseIdentifier)
    }

    func dequeue<T: UITableViewCell>(as cell: T.Type, for indexPath: IndexPath? = nil) -> T? {
        if let idx = indexPath {
            return dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: idx) as? T
        } else {
            return dequeueReusableCell(withIdentifier: cell.reuseIdentifier) as? T
        }
    }
    
    func deselectSelectedRows(animated: Bool = true) {
        indexPathsForSelectedRows?.forEach {
            deselectRow(at: $0, animated: animated)
        }
    }
    
    func batchUpdates(_ updates: (() -> Swift.Void)?, completion: ((Bool) -> Swift.Void)? = nil) {
        if #available(iOS 11, *) {
            performBatchUpdates(updates, completion: completion)
        } else {
            guard let updateBlock = updates else {
                completion?(false)
                return
            }
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                if let completionBlock = completion {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        if Thread.isMainThread {
                            completionBlock(true)
                        } else {
                            DispatchQueue.main.async(execute: {
                                completionBlock(true)
                            })
                        }
                    }
                }
            }
            self.beginUpdates()
            updateBlock()
            self.endUpdates()
            CATransaction.commit()
        }
    }
}

public extension UITableViewCell {
    static var reuseIdentifier: String { return String(describing: self) }

    var parentTableView: UITableView? {
        var parentView: UIView? = self.superview
        while (parentView != nil && (parentView as? UITableView) == nil) {
            parentView = parentView?.superview
        }

        return parentView  as? UITableView
    }

    func setSeparatorFullWidth() {
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }

    func setSeparatorInsets(_ edgeInsets: UIEdgeInsets) {
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = edgeInsets
        self.layoutMargins = UIEdgeInsets.zero
    }

    func setSeparatorInsetsEdges(left: CGFloat, right: CGFloat) {
        var edgeInsets = UIEdgeInsets.zero
        edgeInsets.left = left
        edgeInsets.right = right

        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = edgeInsets
        self.layoutMargins = UIEdgeInsets.zero
    }
    
    class func registerNib(to tableView: UITableView) {
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }

    class func registerClass(to tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }

    class func dequeue(from tableView: UITableView, for indexPath: IndexPath? = nil) -> Self {
        func _dequeue<T>(from tableView: UITableView, for indexPath: IndexPath?) -> T {
            if let idx = indexPath {
                return tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: idx) as! T
            } else {
                return tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier) as! T
            }
        }
        return _dequeue(from: tableView, for: indexPath)
    }
}

public extension UIView {
    var parentTableViewCell: UITableViewCell? {
        var parentView: UIView? = self.superview
        while (parentView != nil && (parentView as? UITableViewCell) == nil) {
            parentView = parentView?.superview
        }

        return parentView  as? UITableViewCell
    }

    var parentCollectionViewCell: UICollectionViewCell? {
        var parentView: UIView? = self.superview
        while (parentView != nil && (parentView as? UICollectionViewCell) == nil) {
            parentView = parentView?.superview
        }

        return parentView  as? UICollectionViewCell
    }
}

open class LHBaseTableView: UITableView {
    override open func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard self.isValidIndexPath(indexPath) else { return }

        super.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }

    open var onTouchBeganEvent: (() -> ())?
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.onTouchBeganEvent?()
    }

    override open func performBatchUpdates(_ updates: (() -> Swift.Void)?, completion: ((Bool) -> Swift.Void)? = nil) {
        batchUpdates(updates, completion: completion)
    }

    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}

public extension UICollectionView {
    var collectionViewFlowLayout: UICollectionViewFlowLayout? {
        return self.collectionViewLayout as? UICollectionViewFlowLayout
    }

    func reloadData(_ completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.reloadData()
        CATransaction.commit()
    }

    func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.item >= 0 && indexPath.section >= 0 && indexPath.section < self.numberOfSections && indexPath.item < self.numberOfItems(inSection: indexPath.section)
    }

    func scrollToLastItem(animated: Bool = true, atScrollPosition: UICollectionView.ScrollPosition = .bottom) {
        let sectionIndex = self.numberOfSections - 1
        guard sectionIndex >= 0 else { return }
        let itemIndex = self.numberOfItems(inSection: sectionIndex) - 1
        let toIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
        guard itemIndex >= 0, self.isValidIndexPath(toIndexPath) else { return }

        self.scrollToItem(at: toIndexPath, at: atScrollPosition, animated: animated)
    }

    func scrollToCell(_ toCell: UICollectionViewCell?, animated: Bool = true, atScrollPosition: UICollectionView.ScrollPosition = .bottom) {
        guard let cell = toCell else { return }
        guard let indexPath = self.indexPath(for: cell), self.isValidIndexPath(indexPath) else { return }

        self.scrollToItem(at: indexPath, at: atScrollPosition, animated: animated)
    }

    func isLastIndexPath(_ indexPath: IndexPath) -> Bool {
        return (indexPath.section == self.numberOfSections - 1) && (indexPath.item == self.numberOfItems(inSection: indexPath.section) - 1)
    }
    
    func register<T: UICollectionViewCell>(_ cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeue<T: UICollectionViewCell>(as cell: T.Type, for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T
    }
}

open class LHBaseCollectionView: UICollectionView {

    override open var collectionViewLayout: UICollectionViewLayout {
        didSet {
            if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
                switch flowLayout.scrollDirection {
                case .horizontal:
                    self.alwaysBounceHorizontal = true
                default:
                    self.alwaysBounceVertical = true
                }
            }
        }
    }

    open var onTouchBeganEvent: (() -> ())?

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.onTouchBeganEvent?()
    }

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}

public extension UICollectionViewCell {
    var parentCollectionView: UICollectionView? {
        var parentView: UIView? = self.superview
        while (parentView != nil && (parentView as? UICollectionView) == nil) {
            parentView = parentView?.superview
        }

        return parentView  as? UICollectionView
    }
    
    class func registerNib(to collectionView: UICollectionView) {
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }

    class func registerClass(to collectionView: UICollectionView) {
        collectionView.register(self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    class func dequeue(from collectionView: UICollectionView, for indexPath: IndexPath) -> Self {
        func _dequeue<T>(from collectionView: UICollectionView, for indexPath: IndexPath) -> T {
            collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! T
        }
        return _dequeue(from: collectionView, for: indexPath)
    }
}

public extension UIScrollView {
    func scrollToBottom(animated: Bool = true) {
        let offset = self.contentSize.height - self.bounds.size.height
        self.setContentOffset(CGPoint(x: 0, y: offset), animated: animated)
    }
}

open class LHBaseScrollView: UIScrollView {
    open var onTouchBeganEvent: (() -> ())?

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        self.onTouchBeganEvent?()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}

public extension UICollectionReusableView {
    static var reuseIdentifier: String { return String(describing: self) }
}

public extension UITableViewHeaderFooterView {
    static var reuseIdentifier: String { return String(describing: self) }
}

public extension UIScrollView {
    func setContentOffset(_ offset: CGPoint, duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.contentOffset = offset
        }, completion: { [unowned self] _ in
            if self.contentOffset != offset {
                self.contentOffset = offset
            }
            self.delegate?.scrollViewDidEndScrollingAnimation?(self)
        })
    }
}
#endif
