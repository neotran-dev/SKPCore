//
//  UITextField+Ex.swift
//  Base Extensions
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if canImport(UIKit)
    import UIKit
#endif

public enum NumericType {
    case Int
    case Int64
    case UInt64
    case Float
    case Double
    case Decimal
}

public extension UITextField {
    var textValue: String { return text ?? .empty }
    
    func shouldChangeCharactersInRange(_ inRange: NSRange, replacementString string: String, maxLength: Int = Int.max) -> (should: Bool, text: String) {
        var result: Bool = true
        let maximumCommentLength = maxLength
        var resultString: String = ((self.text ?? "") as NSString).replacingCharacters(in: inRange, with: string)
        if (string.length > 1) {
            // paste event
            var textControl: NSString = resultString as NSString
            if (textControl.length > maximumCommentLength) {
                var rangeEnum: NSRange = NSRange(location: maximumCommentLength - 2, length: 4)
                if(rangeEnum.location + rangeEnum.length > textControl.length) {
                    rangeEnum.length = textControl.length - rangeEnum.location
                }
                var maxTextInputAvaiable: NSInteger = maximumCommentLength
                textControl.enumerateSubstrings(in: rangeEnum, options: NSString.EnumerationOptions.byComposedCharacterSequences) { (_, substringRange, _, _) -> Void in
                    if(substringRange.location + substringRange.length <= maximumCommentLength) {
                        maxTextInputAvaiable = substringRange.location + substringRange.length
                    }
                }
                textControl = textControl.substring(to: maxTextInputAvaiable) as NSString
                resultString = textControl as String
                result = false
            }
        } else {
            // press keyboard / typing
            if (inRange.length <= 0) {
                result = resultString.length <= maximumCommentLength
                resultString = result ? resultString : (self.text ?? "")
            }
        }
        return (result, resultString)
    }

    func shouldChangeCharactersInRange(numericType: NumericType, groupSeparator: String? = nil, maxValue: Float? = nil, maxFractionDigits: Int? = nil, inRange: NSRange, replacementString string: String) -> Bool {
        let resultString: String = (self.text ?? "").nsString.replacingCharacters(in: inRange, with: string)
        if resultString.isEmpty { return true }
        let result: Bool = resultString.isNumeric(type: numericType, groupSeparator: groupSeparator, maxFractionDigits: maxFractionDigits)
        if let hasMax = maxValue, result == true, hasMax > 0 {
            return (resultString.toFloat(withComma: groupSeparator) ?? 0) <= hasMax
        }
        return result
    }
}

public extension String {
    func isNumeric(type: NumericType, groupSeparator: String? = nil, maxFractionDigits: Int? = nil) -> Bool {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if groupSeparator != nil { formatter.groupingSeparator = groupSeparator }

        switch type {
        case .Float : formatter.allowsFloats = true
        case .Double: formatter.allowsFloats = true
        default     : formatter.allowsFloats = false
        }
        let numericNumber = formatter.number(from: self.replacingOccurrences(of: formatter.groupingSeparator ?? ",", with: ""))
        let decimalSeparator = formatter.decimalSeparator ?? "."
        if maxFractionDigits != nil && numericNumber != nil && self.contains(decimalSeparator) {
            let fractionDigits = self.components(separatedBy: decimalSeparator).last
            return (fractionDigits ?? "").length <= maxFractionDigits!
        }

        return numericNumber != nil
    }

    func numericString(type: NumericType, groupSeparator: String? = nil) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if groupSeparator != nil { formatter.groupingSeparator = groupSeparator }

        switch type {
        case .Float : formatter.allowsFloats = true
        case .Double: formatter.allowsFloats = true
        default     : formatter.allowsFloats = false
        }
        let numericNumber = formatter.number(from: self.replacingOccurrences(of: formatter.groupingSeparator ?? ",", with: ""))
        return numericNumber?.stringValue
    }

    func toFloat(withComma: String? = nil) -> Float? {
        if let strValue = self.numericString(type: .Float, groupSeparator: withComma) {
            return Float(strValue)
        }
        return nil
    }

    func toInt(withComma: String? = nil) -> Int? {
        if let strValue = self.numericString(type: .Int, groupSeparator: withComma) {
            return Int(strValue)
        }
        return nil
    }

    func toDouble(withComma: String? = nil) -> Double? {
        if let strValue = self.numericString(type: .Double, groupSeparator: withComma) {
            return Double(strValue)
        }
        return nil
    }
}

public struct ActionEvents: OptionSet {
    public var rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static var none: ActionEvents { return ActionEvents(rawValue: 0) }
    public static var paste: ActionEvents { return ActionEvents(rawValue: 1 << 0) }
    public static var copy: ActionEvents { return ActionEvents(rawValue: 1 << 1) }
    public static var select: ActionEvents { return ActionEvents(rawValue: 1 << 2) }
    public static var selectAll: ActionEvents { return ActionEvents(rawValue: 1 << 3) }
    public static var delete: ActionEvents { return ActionEvents(rawValue: 1 << 4) }
    public static var all: ActionEvents { return ActionEvents(rawValue: 1 << 5) }
}

@objc public protocol LHBaseTextFieldDelegate: UITextFieldDelegate {
    @objc optional func textFieldTextDidChanged(_ textField: UITextField)
    @objc optional func textFieldDidClickedDeleteBackward(_ textField: UITextField)
}

@IBDesignable
open class LHBaseTextField: UITextField {
    open var disableActionEvents: ActionEvents = .none
    lazy var labelRight: UILabel = {
        return UILabel()
    }()

    open var textContainInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }

    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if ActionEvents.all.isSubset(of: disableActionEvents) { return false }

        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return ActionEvents.paste.isSubset(of: disableActionEvents) ? false : super.canPerformAction(action, withSender: sender)
        } else if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return ActionEvents.copy.isSubset(of: disableActionEvents) ? false : super.canPerformAction(action, withSender: sender)
        } else if action == #selector(UIResponderStandardEditActions.select(_:)) {
            return ActionEvents.select.isSubset(of: disableActionEvents) ? false : super.canPerformAction(action, withSender: sender)
        } else if action == #selector(UIResponderStandardEditActions.selectAll(_:)) {
            return ActionEvents.selectAll.isSubset(of: disableActionEvents) ? false : super.canPerformAction(action, withSender: sender)
        } else if action == #selector(UIResponderStandardEditActions.delete(_:)) {
            return ActionEvents.delete.isSubset(of: disableActionEvents) ? false : super.canPerformAction(action, withSender: sender)
        }

        return super.canPerformAction(action, withSender: sender)
    }

    @IBInspectable open var spaceOnRightAlign: Bool = false
    fileprivate var needReplaceSpaceUnicode: Bool {
        return self.spaceOnRightAlign && self.textAlignment == .right
    }

    override open var text: String? {
        get {
            return self.needReplaceSpaceUnicode ? super.text?.replacingOccurrences(of: "\u{00a0}", with: " ") : super.text
        }
        set {
            super.text = self.needReplaceSpaceUnicode ? newValue?.replacingOccurrences(of: " ", with: "\u{00a0}") : newValue
        }
    }

    @IBInspectable open var placeholderColor: UIColor = UIColor.lightGray.withAlphaComponent(0.7) {
        didSet {
            let attributes = [ NSAttributedString.Key.foregroundColor: placeholderColor ]
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: attributes)
        }
    }

    override open var placeholder: String? {
        didSet {
            let attributes = [ NSAttributedString.Key.foregroundColor: placeholderColor ]
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: attributes)
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        commonInit()
    }

    private func commonInit() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChangeText(_:)), name: UITextField.textDidChangeNotification, object: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func textFieldDidChangeText(_ notification: Notification) {
        if self.needReplaceSpaceUnicode == false {
            self.notifyDelegateTextDidChanged()
            return
        }
        let replaceSpaceWithUnicode = super.text?.replacingOccurrences(of: " ", with: "\u{00a0}")
        if super.text == replaceSpaceWithUnicode {
            self.notifyDelegateTextDidChanged()
            return
        }
        super.text = replaceSpaceWithUnicode
        self.notifyDelegateTextDidChanged()
    }

    private func notifyDelegateTextDidChanged() {
        if let customDelete = self.delegate as? LHBaseTextFieldDelegate, customDelete.responds(to: #selector(LHBaseTextFieldDelegate.textFieldTextDidChanged(_:))) {
            customDelete.textFieldTextDidChanged?(self)
        }
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentInsetPadding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentInsetPadding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentInsetPadding)
    }

    private var contentInsetPadding: UIEdgeInsets {
        var mInset = textContainInsets
        mInset.right += paddingRightView
        return mInset
    }
    private var paddingRightView: CGFloat = 0

    open var rightStringColor: UIColor = UIColor.lightGray {
        didSet { labelRight.textColor = rightStringColor }
    }

    open var rightString: String? {
        didSet {
            if let rightValue = rightString, !rightValue.isEmpty {
                labelRight.frame = CGRect(x: 0, y: 0, width: 50, height: self.height)
                labelRight.text = rightValue
                labelRight.textColor = rightStringColor
                labelRight.font = self.font
                labelRight.textAlignment = .left
                labelRight.sizeToFit()
                var labelFrame = labelRight.frame
                labelFrame.size.height = self.height - 8
                labelFrame.size.width = labelFrame.width + 4
                labelRight.frame = labelFrame
                self.paddingRightView = labelRight.width
                self.rightView = labelRight
                self.rightViewMode = .always
            } else {
                self.rightView = nil
                self.paddingRightView = 0
            }
        }
    }
    
    open override func deleteBackward() {
        super.deleteBackward()
        
        if let customDelete = self.delegate as? LHBaseTextFieldDelegate, customDelete.responds(to: #selector(LHBaseTextFieldDelegate.textFieldDidClickedDeleteBackward(_:))) {
            customDelete.textFieldDidClickedDeleteBackward?(self)
        }
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
