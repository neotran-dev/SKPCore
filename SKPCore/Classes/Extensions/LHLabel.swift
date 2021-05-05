//
//  LHLabel.swift
//  LHCoreExtensions iOS
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit

open class LHLabel: UILabel {
    open var textContainInsets: UIEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0) {
        didSet { setNeedsDisplay() }
    }
    
    open var isEnabledTextContainInsetWhenEmpty: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    fileprivate var getCorrectTextContainInset: UIEdgeInsets {
        if !isEnabledTextContainInsetWhenEmpty && (String.isEmpty(text) || String.isEmpty(attributedText?.string)) {
            return UIEdgeInsets.zero
        }
        
        return textContainInsets
    }
    
    override open func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let correctTextContainInset = getCorrectTextContainInset
        let insetRect = bounds.inset(by: correctTextContainInset)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        
        return textRect.inset(by: correctTextContainInset.inverted)
    }
    
    override open func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: getCorrectTextContainInset))
    }
    
    @IBInspectable
    var textInsetsLeft: CGFloat {
        get { return textContainInsets.left }
        set { textContainInsets.left = newValue }
    }
    @IBInspectable
    var textInsetsRight: CGFloat {
        get { return textContainInsets.right }
        set { textContainInsets.right = newValue }
    }
    @IBInspectable
    var textInsetsTop: CGFloat {
        get { return textContainInsets.top }
        set { textContainInsets.top = newValue }
    }
    @IBInspectable
    var textInsetsBottom: CGFloat {
        get { return textContainInsets.bottom }
        set { textContainInsets.bottom = newValue }
    }
}
#endif
