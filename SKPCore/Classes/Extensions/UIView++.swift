//
//  UIView++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/19/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
public enum ViewBlurStyle: Int {
    case extraLight = 1, light = 2, dark = 3
}
@IBDesignable
public extension UIView {
    @IBInspectable var blurStyle: Int {
        get {
            if self.viewWithTag(99996) as? UIVisualEffectView != nil { return 1}
            if self.viewWithTag(99997) as? UIVisualEffectView != nil { return 2}
            if self.viewWithTag(99998) as? UIVisualEffectView != nil { return 3}
            return 0
        }
        set {
            switch newValue {
            case 1,2,3:
                var blurEffectView: UIVisualEffectView!
                if newValue == 1 {
                    blurEffectView = UIVisualEffectView(effect:UIBlurEffect(style: .extraLight))
                    blurEffectView.tag = 99996
                }
                else if newValue == 2 {
                    blurEffectView = UIVisualEffectView(effect:UIBlurEffect(style: .light))
                    blurEffectView.tag = 99997
                }
                else if newValue == 3 {
                    blurEffectView = UIVisualEffectView(effect:UIBlurEffect(style: .dark))
                    blurEffectView.tag = 99998
                }
                blurEffectView.frame = self.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.clipsToBounds = true
                self.insertSubview(blurEffectView, at: 0)
            default:
                break
            }
        }
    }
}
public extension UIView {
    
    func connectNibUI(usePadSuffix: Bool = false) {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let typeName = String(describing: type(of: self))
        let nibName = usePadSuffix ? (isPad ? "\(typeName)_Pad" : typeName) : typeName
        let nib = UINib(nibName: nibName, bundle: nil).instantiate(withOwner: self, options: nil)
        guard let nibView = nib.first as? UIView else {
            fatalError("Nib is not correct")
        }
        nibView.backgroundColor = .clear
        self.addSubview(nibView)
        nibView.translatesAutoresizingMaskIntoConstraints = false
        nibView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        nibView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        nibView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        nibView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
    
    func addShadow(withCornerRadius radius: CGFloat = 0, shadowRadius: CGFloat = 5, shadowColor: UIColor = UIColor.black, shadowOpacity: Float = 0.3, shadowOffset: CGSize = .zero) {
        layer.cornerRadius = radius
        layer.masksToBounds = false
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    func showProgressIndicator(size: CGFloat = 20, style: UIActivityIndicatorView.Style = .gray, inset: UIEdgeInsets = .zero) {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tag = 1001
        indicator.startAnimating()
        
        self.addSubview(indicator)
        self.bringSubviewToFront(indicator)
        indicator.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(size)
            guard inset != .zero else {
                maker.centerY.equalToSuperview()
                maker.centerX.equalToSuperview()
                return
            }
            if inset.top != 0 { maker.top.equalToSuperview().offset(inset.top) }
            if inset.left != 0 { maker.left.equalToSuperview().offset(inset.left) }
            if inset.right != 0 { maker.right.equalToSuperview().offset(-inset.right) }
            if inset.bottom != 0 { maker.bottom.equalToSuperview().offset(-inset.bottom) }
        }
    }
    
    func hideProgressIndicator() {
        self.viewWithTag(1001)?.removeFromSuperview()
    }
    
    func pulsate(completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            completion?()
        })
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
        CATransaction.commit()
    }
    
    func flash(completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            completion?()
        })
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
        CATransaction.commit()
    }
    
    
    func shake(completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            completion?()
        })
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.repeatCount = 2
        shake.autoreverses = true
    
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
        CATransaction.commit()
    }
    
    var heightConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }

    var widthConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .width && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
}

public extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

public extension UIView {
    func add(view: UIView, inset: UIEdgeInsets = .zero) {
        addSubview(view)
        self.snp.removeConstraints()
        view.snp.makeConstraints({ maker in
            maker.top.equalToSuperview().inset(inset.top)
            maker.left.equalToSuperview().inset(inset.left)
            maker.bottom.equalToSuperview().inset(-inset.bottom)
            maker.right.equalToSuperview().inset(-inset.right)
        })
    }
}

public extension UIView {

    private static let kLayerNameGradientBorder = "GradientBorderLayer"

    func gradientBorder(width: CGFloat,
                        colors: [UIColor],
                        startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
                        endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0),
                        andRoundCornersWithRadius cornerRadius: CGFloat = 0) {

        guard let existingBorder = gradientBorderLayer() else {
            let border =  CAGradientLayer()
            border.name = UIView.kLayerNameGradientBorder
            border.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y,
                                  width: bounds.size.width + width, height: bounds.size.height + width)
            border.colors = colors.map { return $0.cgColor }
            border.startPoint = startPoint
            border.endPoint = endPoint

            let mask = CAShapeLayer()
            let maskRect = CGRect(x: bounds.origin.x + width/2, y: bounds.origin.y + width/2,
                                  width: bounds.size.width - width, height: bounds.size.height - width)
            mask.path = UIBezierPath(ovalIn: maskRect).cgPath
            mask.fillColor = UIColor.clear.cgColor
            mask.strokeColor = UIColor.white.cgColor
            mask.lineWidth = width

            border.mask = mask
            layer.addSublayer(border)
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
            return
        }
    }
    
    private func gradientBorderLayer() -> CAGradientLayer? {
        guard let borderLayer = layer.sublayers?.first { return $0.name == UIView.kLayerNameGradientBorder } as? CAGradientLayer else {
            return nil
        }
        return borderLayer
    }
    
    func removeGradientBorder() {
        layer.sublayers?.first { return $0.name == UIView.kLayerNameGradientBorder }?.removeFromSuperlayer()
    }
}
