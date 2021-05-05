//
//  UIScrollView++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/4/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
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
    
    func setup(withViewForAnimate headerView: UIView, topConstraint: NSLayoutConstraint, isRevered: Bool = false) {
        
        let originalY = topConstraint.constant
        
        let yRange: Range<CGFloat> = originalY..<originalY + headerView.height
        
        self.contentInset = UIEdgeInsets(top: headerView.height, left: 0, bottom: 0, right: 0)
    
        self.rx.didScroll.subscribe(onNext: { [weak self] in
            guard let me = self else { return }
            let y: CGFloat = me.contentOffset.y + me.contentInset.top
            if y > yRange.upperBound {
                guard topConstraint.constant != yRange.upperBound else { return }
                topConstraint.constant = yRange.upperBound  * (isRevered ? -1 : 1)
                headerView.alpha = 0
            } else if y < yRange.lowerBound {
                guard topConstraint.constant != yRange.lowerBound else { return }
                topConstraint.constant = yRange.lowerBound  * (isRevered ? -1 : 1)
                headerView.alpha = 1
            } else {
                topConstraint.constant = y * (isRevered ? -1 : 1)
                headerView.alpha =  1 - (y / yRange.upperBound)
            }
        }).disposed(by: rx.disposeBag)
    }
}


