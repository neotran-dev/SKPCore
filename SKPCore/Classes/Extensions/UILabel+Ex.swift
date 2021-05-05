//
//  UILabel+Ex.swift
//  LHCoreSDK iOS
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 Alamofire. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
    import Cocoa
#endif

class LHLabelInset: UILabel {
    var textContainInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet { setNeedsDisplay() }
    }
    
    var isEnabledTextContainInsetWhenEmpty: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    fileprivate var getCorrectTextContainInset: UIEdgeInsets {
        if !isEnabledTextContainInsetWhenEmpty && (String.isEmpty(text) || String.isEmpty(attributedText?.string)) {
            return UIEdgeInsets.zero
        }
        
        return textContainInset
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let correctTextContainInset = getCorrectTextContainInset
        let insetRect = bounds.inset(by: correctTextContainInset)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        
        return textRect.inset(by: correctTextContainInset.inverted)
    }
    
    override open func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: getCorrectTextContainInset))
    }
    
    @IBInspectable
    fileprivate var textInsetLeft: CGFloat = 20 {
        didSet {
            textContainInset.left = textInsetLeft
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    fileprivate var textInsetRight: CGFloat = 20 {
        didSet {
            textContainInset.right = textInsetRight
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    fileprivate var textInsetBottom: CGFloat = 20 {
        didSet {
            textContainInset.bottom = textInsetBottom
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    fileprivate var textInsetTop: CGFloat = 20 {
        didSet {
            textContainInset.top = textInsetTop
            setNeedsDisplay()
        }
    }
}
#endif
