//
//  UIScrollView++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/4/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxSwiftExt
import WebKit

public extension UIScrollView {
    var isBouncing: Bool {
        var isBouncing = false
        if contentOffset.y >= (contentSize.height - bounds.size.height) {
            // Bottom bounce
            isBouncing = true
        } else if contentOffset.y < contentInset.top {
            // Top bounce
            isBouncing = true
        }
        return isBouncing
    }
    
    func isScrollToBottom() -> Bool {
        let currentOffset = contentOffset.y
        let maximumOffset = contentSize.height - frame.size.height
        print("currentOffset \(currentOffset) - maximumOffset\(maximumOffset)")
        return  (maximumOffset - currentOffset) <= 10.0
    }
    
    
    func scrollToTop(animated: Bool = false) {
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: animated)
    }
    
    func setup(withViewForAnimate animatedView: UIView, topConstraint: NSLayoutConstraint, originalY: CGFloat = 0) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard var me = self else { return }
            me.rx.disposeBag = DisposeBag()
            me.setContentOffset(CGPoint(x: 0, y: -1 * animatedView.height), animated: false)
            me.contentInset = UIEdgeInsets(top: animatedView.height, left: 0, bottom: 0, right: 0)
            me.setupAnimateViewWhenScroll(withViewForAnimate: animatedView, topConstraint: topConstraint, originalY: originalY)
        } completion: { [weak self] finished in
            guard let me = self, finished else { return }
            me.rx.didScroll.subscribe(onNext: {
                me.setupAnimateViewWhenScroll(withViewForAnimate: animatedView, topConstraint: topConstraint, originalY: originalY)
            }).disposed(by: me.rx.disposeBag)
        }
    }
    
    private func setupAnimateViewWhenScroll(withViewForAnimate animatedView: UIView, topConstraint: NSLayoutConstraint, originalY: CGFloat) {
        let y: CGFloat = (contentOffset.y + contentInset.top)
        let yRange: Range<CGFloat> = originalY ..< originalY + animatedView.height
        // print("Y: \(y) - Range Y: \(yRange.lowerBound) - \(yRange.upperBound)")
        if  y > yRange.upperBound {
            guard topConstraint.constant != yRange.upperBound else { return }
            topConstraint.constant = -1 * yRange.upperBound
            animatedView.alpha = 0
        } else if y < yRange.lowerBound {
            guard topConstraint.constant != yRange.lowerBound else { return }
            topConstraint.constant = -1 * yRange.lowerBound
            animatedView.alpha = 1
        } else {
            topConstraint.constant = -y
            animatedView.alpha =  1 - (y / yRange.upperBound)
        }
    }
}


