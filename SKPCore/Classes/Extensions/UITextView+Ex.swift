//
//  UITextView+Ex.swift
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

public extension UITextView {
    var textValue: String { return text ?? .empty }
    
    func shouldChangeTextInRange(_ range: NSRange, replacementText text: String, maxLength: Int = Int.max) -> (should: Bool, text: String?) {
        var result: Bool = true
        let commentInput = text as NSString
        let maximumCommentLength = maxLength
        var resultString: String?
        if (commentInput.length > 1) {
            // paste event
            var textControl: NSString = (self.text as NSString).replacingCharacters(in: range, with: text) as NSString
            if (textControl.length > maximumCommentLength) {
                var rangeEnum: NSRange = NSMakeRange(maximumCommentLength - 2, 4)
                if(rangeEnum.location + rangeEnum.length > textControl.length) {
                    rangeEnum.length = textControl.length - rangeEnum.location
                }
                var maxTextInputAvaiable: NSInteger = maximumCommentLength
                textControl.enumerateSubstrings(in: rangeEnum, options: NSString.EnumerationOptions.byComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) -> () in
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
            if (range.length <= 0) {
                let textControl: NSString = (self.text as NSString).replacingCharacters(in: range, with: text) as NSString
                result = textControl.length <= maximumCommentLength
            }
        }

        return (result, resultString)
    }
}

@objc public protocol LHBaseTextViewDelegate: UITextViewDelegate {
    @objc optional func textViewDidClickedDeleteBackward(_ textView: UITextView)
}

open class LHBaseTextView: UITextView {
    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.alpha = 1.0
        
        return label
    }()

    @IBInspectable
    open var placeholderColor: UIColor = UIColor.lightGray.withAlphaComponent(0.7) {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }

    @IBInspectable
    open var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    override open var text: String! {
        didSet {
            handleTextDidChanged(nil)
        }
    }

    open override var attributedText: NSAttributedString! {
        didSet {
            handleTextDidChanged(nil)
        }
    }

    override open var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }

    override open var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }

    var placeholderLabelConstraints = [NSLayoutConstraint]()

    fileprivate func commonInit() {
        guard placeholderLabel.superview != self else { return }

        let cFont = self.font ?? UIFont.systemFont(ofSize: 14.0)
        self.font = cFont

        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.text = placeholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        updateConstraintsForPlaceholderLabel()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextDidChanged(_:)),
            name: UITextView.textDidChangeNotification,
            object: nil
        )

        handleTextDidChanged(nil)
    }

    open override var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        commonInit()
    }

    public convenience init() {
        self.init(frame: CGRect.zero, textContainer: nil)
    }

    public convenience init(frame: CGRect) {
        self.init(frame: frame, textContainer: nil)
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        commonInit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    @objc func handleTextDidChanged(_ notification:Notification?) {
        handlePlaceholderLabel()
    }

    func handlePlaceholderLabel() {
        placeholderLabel.isHidden = !String.isEmpty(text)
    }

    func updateConstraintsForPlaceholderLabel() {
        var newConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeholderLabel])
        newConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeholderLabel])
        newConstraints.append(NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1.0,
            constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)
        ))
        removeConstraints(placeholderLabelConstraints)
        addConstraints(newConstraints)
        placeholderLabelConstraints = newConstraints
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }
    
    open override func deleteBackward() {
        super.deleteBackward()
        
        if let customDelete = self.delegate as? LHBaseTextViewDelegate, customDelete.responds(to: #selector(LHBaseTextViewDelegate.textViewDidClickedDeleteBackward(_:))) {
            customDelete.textViewDidClickedDeleteBackward?(self)
        }
    }
}
#endif
