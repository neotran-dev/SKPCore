//
//  UIView+Ex.swift
//  Base Extensions
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

public extension NSUIView {
    var xFrame: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    var yFrame: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    var width: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }
    var height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }
    var centerSelf: CGPoint { return CGPoint(x: width / 2.0, y: height / 2.0) }
    
    class var nibNameClass: String? {
        return "\(self)".components(separatedBy: ".").first
    }
    
    class var nib: NSUINib? {
        guard Bundle.main.path(forResource: nibNameClass, ofType: "nib") != nil else { return nil }
        #if os(iOS) || os(tvOS)
        return NSUINib(nibName: nibNameClass ?? "", bundle: nil)
        #elseif os(OSX)
        return NSUINib(nibNamed: NSNib.Name(nibNameClass ?? ""), bundle: nil)
        #else
        return nil
        #endif
    }
    
    class func nib(bundle: Bundle = Bundle.main) -> NSUINib? {
        guard bundle.path(forResource: nibNameClass, ofType: "nib") != nil else { return nil }
        
        #if os(iOS) || os(tvOS)
        return NSUINib(nibName: nibNameClass ?? "", bundle: bundle)
        #elseif os(OSX)
        return NSUINib(nibNamed: NSNib.Name(nibNameClass ?? ""), bundle: bundle)
        #else
        return nil
        #endif
    }
    
    class func fromNib(nibNameOrNil: String? = nil, inBundle: Bundle = Bundle.main) -> Self? {
        return fromNib(nibNameOrNil: nibNameOrNil, type: self, inBundle: inBundle)
    }
    
    class func fromNib<T: NSUIView>(nibNameOrNil: String? = nil, type: T.Type, inBundle: Bundle = Bundle.main) -> T? {
        let nibName = (nibNameOrNil ?? nibNameClass) ?? ""
        guard inBundle.path(forResource: nibName, ofType: "nib") != nil else { return nil }
        
        #if os(iOS) || os(tvOS)
        guard let nibViews = inBundle.loadNibNamed(nibName, owner: nil, options: nil), nibViews.count > 0 else { return nil }
        
        for view in nibViews where view is T {
            return view as? T
        }
        #elseif os(OSX)
        var nibViews: NSArray?
        inBundle.loadNibNamed(NSNib.Name(nibName), owner: nil, topLevelObjects: &nibViews)
        guard let views = nibViews, views.count > 0 else { return nil }
        
        for view in views where view is T {
            return view as? T
        }
        #endif
        return nil
    }
    
    #if os(iOS) || os(tvOS)
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func captured(withScale: CGFloat = 0.0) -> UIImage? {
        var capturedImage: UIImage?
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, withScale)
        if let currentContext = UIGraphicsGetCurrentContext() {
            self.layer.render(in: currentContext)
            capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        UIGraphicsEndImageContext()
        return capturedImage
    }
    
    func rotate(degree: CGFloat = 0, duration: TimeInterval = 0) {
        DispatchQueue.mainAsync { [weak self] in
            UIView.animate(withDuration: duration) {
                self?.transform = CGAffineTransform(rotationAngle: CGFloat.pi * degree / 180.0)
            }
        }
    }
    #endif
}

#if os(iOS) || os(tvOS)
@IBDesignable
extension UIView {
    @IBInspectable
    open var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set {
            layer.borderWidth = newValue
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    open var borderColor: UIColor? {
        get { return layer.borderColor == nil ? nil : UIColor(cgColor: layer.borderColor!) }
        set {
            layer.borderColor = newValue?.cgColor
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    @objc public func setCornerRadius(_ radius: CGFloat, width: CGFloat = 0, color: UIColor? = nil) {
        layer.cornerRadius = radius
        layer.borderWidth = width
        layer.borderColor = color?.cgColor
        if radius > 0 {
            clipsToBounds = true
        }
    }
    
    @available(iOS 11, *)
    @objc public func setCornersMasked(corners: UIRectCorner, radius: CGFloat, borderWidth: CGFloat = 0, color: UIColor? = nil) {
        layer.cornerRadius = radius
        layer.borderWidth = borderWidth
        layer.borderColor = color?.cgColor
        layer.maskedCorners = corners.caCornerMask
        if radius > 0 { clipsToBounds = true }
    }
    
    @objc public func applySketchShadow(color: UIColor = .black, opacity: Float = 1.0,
                                        x: CGFloat = 0, y: CGFloat = -3, blur: CGFloat = 6, spread: CGFloat = 0)
    {
        layer.applySketchShadow(color: color, opacity: opacity, x: x, y: y, blur: blur, spread: spread)
    }
    
    func add(to superview: UIView, belowSubview: UIView? = nil, aboveSubview: UIView? = nil) {
        if let below = belowSubview {
            superview.insertSubview(self, belowSubview: below)
        } else if let above = aboveSubview {
            superview.insertSubview(self, aboveSubview: above)
        } else {
            superview.addSubview(self)
        }
    }
    
    func sizeThatFits(width: CGFloat = CGFloat.greatestFiniteMagnitude,
                      height: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        sizeThatFits(CGSize(width: width, height: height))
    }
    
    @discardableResult
    func setLayout(
        _ attr1: NSLayoutConstraint.Attribute, is relation: NSLayoutConstraint.Relation = .equal,
        to: (view: Any, attribute: NSLayoutConstraint.Attribute)? = nil,
        multiplier: CGFloat = 1, constant: CGFloat = 0, activate: Bool = true) -> NSLayoutConstraint {
        let lc = NSLayoutConstraint(
            item: self, attribute: attr1, relatedBy: relation,
            toItem: to?.view, attribute: to?.attribute ?? .notAnAttribute,
            multiplier: multiplier, constant: constant
        )
        lc.isActive = activate
        return lc
    }
    
    @discardableResult
    @available(iOS 9.0, *)
    func constraint(
        equalToAnchorOf view: UIView,
        safeArea: Bool = false,
        top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0
    ) -> (top: NSLayoutConstraint, left: NSLayoutConstraint, bottom: NSLayoutConstraint, right: NSLayoutConstraint) {
        let topConst = topAnchor.constraint(equalTo: safeArea ? view.safeAreaTopAnchor : view.topAnchor, constant: top).activate()
        let leftConst = leftAnchor.constraint(equalTo: safeArea ? view.safeAreaLeftAnchor : view.leftAnchor, constant: left).activate()
        let bottomConst = bottomAnchor.constraint(equalTo: safeArea ? view.safeAreaBottomAnchor : view.bottomAnchor, constant: bottom).activate()
        let rightConst = rightAnchor.constraint(equalTo: safeArea ? view.safeAreaRightAnchor : view.rightAnchor, constant: right).activate()
        return (top: topConst, left: leftConst, bottom: bottomConst, right: rightConst)
    }
}

@available(iOS 9.0, *)
public extension UIStackView {
    func removeAllArrangedSubview(fromSuperview: Bool = true) {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            if fromSuperview { $0.removeFromSuperview() }
        }
    }
}

extension CALayer {
    internal func applySketchShadow(
        color: NSUIColor = .black,
        opacity: Float = 1.0,
        x: CGFloat = 0,
        y: CGFloat = -3,
        blur: CGFloat = 6,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = NSUIBezierPath(rect: rect).cgPath
        }
        masksToBounds = false
    }
}

extension UIRectCorner {
    var caCornerMask: CACornerMask {
        guard !self.contains(.allCorners) else { return [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner] }
        
        var caMask: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        if !self.contains(.bottomLeft) { caMask.remove(.layerMinXMaxYCorner) }
        if !self.contains(.bottomRight) { caMask.remove(.layerMaxXMaxYCorner) }
        if !self.contains(.topLeft) { caMask.remove(.layerMinXMinYCorner) }
        if !self.contains(.topRight) { caMask.remove(.layerMaxXMinYCorner) }
        
        return caMask
    }
}

extension CACornerMask {
    var rectCorner: UIRectCorner {
        if self.contains([.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]) { return .allCorners }
        
        var corner: UIRectCorner = [.bottomLeft, .bottomRight, .topLeft, .topRight]
        if !self.contains(.layerMinXMaxYCorner) { corner.remove(.bottomLeft) }
        if !self.contains(.layerMaxXMaxYCorner) { corner.remove(.bottomRight) }
        if !self.contains(.layerMinXMinYCorner) { corner.remove(.topLeft) }
        if !self.contains(.layerMaxXMinYCorner) { corner.remove(.topRight) }
        return corner
    }
}

public extension UIViewAnimating {
    @available(iOS 10.0, *)
    func finish(at finalPosition: UIViewAnimatingPosition = .current) {
        stopAnimation(false)
        finishAnimation(at: finalPosition)
    }
}

@available(iOS 9.0, *)
public extension NSUIView {
    var safeAreaLeadingAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.leadingAnchor
    }
    
    var safeAreaTrailingAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.trailingAnchor
    }
    
    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.leftAnchor
    }
    
    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.rightAnchor
    }
    
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.topAnchor
    }
    
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.bottomAnchor
    }
    
    var safeAreaWidthAnchor: NSLayoutDimension {
        return safeAreaLayoutGuide.widthAnchor
    }
    
    var safeAreaHeightAnchor: NSLayoutDimension {
        return safeAreaLayoutGuide.heightAnchor
    }
    
    var safeAreaCenterXAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.centerXAnchor
    }
    
    var safeAreaCenterYAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.centerYAnchor
    }
}

#endif

public extension NSLayoutConstraint {
    @discardableResult
    func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }
}
