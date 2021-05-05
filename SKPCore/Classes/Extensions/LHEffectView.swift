//
//  TestLHEffectView.swift
//  TestUIView
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
    import Cocoa
#endif

public extension CAGradientLayerType {
    static let linear = CAGradientLayerType.axial
}

/// The direction of the gradient.
public enum LHGradientDirection {
    /// The gradient is vertical.
    case vertical

    /// The gradient is horizontal
    case horizontal

    case diagonalUp

    case diagonalDown

    /// The gradient with position:
    /// [0,0] is the bottom-left corner of the layer, [1,1] is the top-right corner.
    case position((startPoint: CGPoint, endPoint: CGPoint))
}

public func == (lhs: LHGradientDirection, rhs: LHGradientDirection) -> Bool {
    switch (lhs, rhs) {
    case ( .vertical, .vertical): return true
    case ( .horizontal, .horizontal): return true
    case ( .diagonalUp, .diagonalUp): return true
    case ( .diagonalDown, .diagonalDown): return true
    case (.position(let lhsPoint), .position(let rhsPoint)): return lhsPoint == rhsPoint
    default: return false
    }
}

public extension UIRectCorner {
    var isCornerAll: Bool {
        if self.contains(.allCorners) { return true }
        if !self.contains(.topLeft) { return false }
        if !self.contains(.topRight) { return false }
        if !self.contains(.bottomLeft) { return false }
        if !self.contains(.bottomRight) { return false }
        return true
    }
}

@IBDesignable
open class LHEffectView: UIView {
    lazy var gradientLayer: CAGradientLayer = {
        return CAGradientLayer()
    }()

    lazy var shapeLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()

    internal var privateBackgroundColor: UIColor? = UIColor.white
    open override var backgroundColor: UIColor? {
        get { return privateBackgroundColor }
        set {
            super.backgroundColor = UIColor.clear
            privateBackgroundColor = newValue
        }
    }

    // MARK: Corner Border ========================================================
    fileprivate var privateCornerRadius: CGFloat = 0.0 { didSet { updateBorderCorners() } }
    fileprivate var privateBorderWidth: CGFloat = 0.0 { didSet { updateBorderCorners() } }
    fileprivate var privateBorderColor: UIColor? = UIColor.lightGray { didSet { updateBorderCorners() } }

    open var cornersAt: UIRectCorner = .allCorners { didSet { updateBorderCorners() } }

    override open var cornerRadius: CGFloat {
        get { return self.privateCornerRadius }
        set { self.privateCornerRadius = newValue }
    }

    override open var borderWidth: CGFloat {
        get { return self.privateBorderWidth }
        set { self.privateBorderWidth = newValue }
    }

    override open var borderColor: UIColor? {
        get { return self.privateBorderColor }
        set { self.privateBorderColor = newValue }
    }

    @IBInspectable
    var cornerTopLeft: Bool {
        get { return cornersAt.contains(.topLeft) || cornersAt == .allCorners }
        set {
            mergeCorner(.topLeft, isEnable: newValue)
        }
    }
    @IBInspectable
    var cornerTopRight: Bool {
        get { return cornersAt.contains(.topRight) || cornersAt == .allCorners }
        set { mergeCorner(.topRight, isEnable: newValue) }
    }
    @IBInspectable
    var cornerBottomLeft: Bool {
        get { return cornersAt.contains(.bottomLeft) || cornersAt == .allCorners }
        set { mergeCorner(.bottomLeft, isEnable: newValue) }
    }
    @IBInspectable
    var cornerBottomRight: Bool {
        get { return cornersAt.contains(.bottomRight) || cornersAt == .allCorners }
        set { mergeCorner(.bottomRight, isEnable: newValue) }
    }

    internal func mergeCorner(_ corner: UIRectCorner, isEnable: Bool) {
        if isEnable {
            if cornersAt.contains(corner) || cornersAt == .allCorners {
                return
            }
            cornersAt.formUnion(corner)
        } else {
            cornersAt.remove(corner)
        }
        updateBorderCorners()
    }

    internal func updateBorderCorners() {
        setUpdateNeeds()
    }

    // MARK: Gradient ========================================================
    open var direction: LHGradientDirection = .vertical {
        didSet {
            updateGradient()
            setUpdateNeeds()
        }
    }
    open var colors: [UIColor]? {
        didSet {
            updateGradient()
            setUpdateNeeds()
        }
    }
    open var locations: [Float]? {
        didSet {
            updateGradient()
            setUpdateNeeds()
        }
    }
    open var gradientType: CAGradientLayerType = .linear {
        didSet {
            updateGradient()
            setUpdateNeeds()
        }
    }

    internal func updateGradient() {
        gradientLayer.type = gradientType
        gradientLayer.locations = locations?.map({ (loc) -> NSNumber in
            return NSNumber(value: loc)
        })

        if let gColors = colors, gColors.count > 0 {
            gradientLayer.colors = colors?.map({ (gColor) -> CGColor in
                return gColor.cgColor
            })
        } else if let bkgColor = self.backgroundColor {
            gradientLayer.colors = [bkgColor.cgColor, bkgColor.cgColor]
        }

        switch direction {
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        case .diagonalUp:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        case .diagonalDown:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)

        case .position(let position):
            gradientLayer.startPoint = position.startPoint
            gradientLayer.endPoint = position.endPoint
        }

        layer.backgroundColor = UIColor.clear.cgColor
    }

    internal func setUpdateNeeds() {
        setNeedsDisplay()
    }

    @IBInspectable
    var verticalDirection: Bool {
        get { return direction == .vertical }
        set { direction = newValue ? .vertical : .horizontal }
    }

    @IBInspectable
    var startColor: UIColor? {
        didSet {
            var mColors = colors ?? [UIColor]()
            if mColors.count > 0 { mColors.remove(at: 0) }

            if let sColor = startColor {
                mColors.insert(sColor, at: 0)
            }

            self.colors = mColors
        }
    }

    @IBInspectable
    var endColor: UIColor? {
        didSet {
            var mColors = colors ?? [UIColor]()
            if mColors.count > 1 { mColors.removeLast() }

            if let eColor = endColor {
                mColors.append(eColor)
            }
            self.colors = mColors
        }
    }

    // MARK: Shadow ========================================================
    @IBInspectable
    open var shadowColor: UIColor? = UIColor.clear {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
            setUpdateNeeds()
        }
    }

    @IBInspectable
    open var shadowOpacity: Float = 1.0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
            setUpdateNeeds()
        }
    }

    @IBInspectable
    open var shadowOffset: CGPoint = CGPoint(x: 0, y: -3) {
        didSet {
            layer.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
            setUpdateNeeds()
        }
    }

    @IBInspectable
    open var shadowBlur: CGFloat = 6.0 {
        didSet {
            layer.shadowRadius = shadowBlur / 2
            setUpdateNeeds()
        }
    }

    open var shadowSpread: CGFloat = 0.0 {
        didSet {
            setUpdateNeeds()
        }
    }

    // MARK: Render UI ========================================================
    internal func updateEffects() {
        updateGradient()
        updateBorderCorners()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.updateEffects()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.updateEffects()
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        self.updateEffects()
    }

    open override var frame: CGRect {
        didSet {
            shapeLayer.frame = layer.bounds
            gradientLayer.frame = layer.bounds
            setUpdateNeeds()
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        setUpdateNeeds()
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        let gradientPath = self.makePath(self.borderWidth)
        self.borderColor?.setStroke()
        gradientPath.stroke()

        shapeLayer.frame = layer.bounds
        shapeLayer.path = gradientPath.cgPath

        gradientLayer.frame = layer.bounds
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.mask = shapeLayer

        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        layer.shadowRadius = shadowBlur / 2

        if shadowSpread == 0.0 { layer.shadowPath = nil }
        else {
            let dx = -shadowSpread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }

    internal func makePath(_ offset: CGFloat = 0) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = self.borderWidth * 2
        let offsetRect = offset
        //
        path.move(to: CGPoint(x: cornerRadius + offsetRect, y: offsetRect))

        // Top Right
        path.addLine(to: CGPoint(x: self.width - cornerRadius - offsetRect, y: offsetRect))
        if cornersAt.contains(UIRectCorner.topRight) {
            path.addArc(withCenter: CGPoint(x: self.width - cornerRadius - offsetRect, y: cornerRadius + offsetRect), radius: cornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: 0.0, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: self.width - offsetRect, y: offsetRect))
            path.addLine(to: CGPoint(x: self.width - offsetRect, y: cornerRadius + offsetRect))
        }

        // Bottom Right
        path.addLine(to: CGPoint(x: self.width - offsetRect, y: self.height - cornerRadius - offsetRect))
        if cornersAt.contains(UIRectCorner.bottomRight) {
            path.addArc(withCenter: CGPoint(x: self.width - cornerRadius - offsetRect, y: self.height - cornerRadius - offsetRect), radius: cornerRadius, startAngle: 0.0, endAngle: CGFloat.pi / 2.0, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: self.width - offsetRect, y: self.height - offsetRect))
            path.addLine(to: CGPoint(x: self.width - cornerRadius - offsetRect, y: self.height - offsetRect))
        }

        // Bottom Left
        path.addLine(to: CGPoint(x: cornerRadius + offsetRect, y: self.height - offsetRect))
        if cornersAt.contains(UIRectCorner.bottomLeft) {
            path.addArc(withCenter: CGPoint(x: cornerRadius + offsetRect, y: self.height - cornerRadius - offsetRect), radius: cornerRadius, startAngle: CGFloat.pi / 2.0, endAngle: CGFloat.pi, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: offsetRect, y: self.height - offsetRect))
            path.addLine(to: CGPoint(x: offsetRect, y: self.height - cornerRadius - offsetRect))
        }

        // Top Left
        path.addLine(to: CGPoint(x: offsetRect, y: cornerRadius + offsetRect))
        if cornersAt.contains(UIRectCorner.topLeft) {
            path.addArc(withCenter: CGPoint(x: cornerRadius + offsetRect, y: cornerRadius + offsetRect), radius: cornerRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: offsetRect, y: offsetRect))
            path.addLine(to: CGPoint(x: cornerRadius + offsetRect, y: offsetRect))
        }

        return path
    }

    @objc public override func setCornerRadius(_ radius: CGFloat, width: CGFloat = 0, color: UIColor? = nil) {
        self.cornerRadius = radius
        self.borderColor = color
        self.borderWidth = width
    }

    @objc public override func applySketchShadow(color: UIColor = .black, opacity: Float = 1.0,
                                        x: CGFloat = 0, y: CGFloat = -3, blur: CGFloat = 6, spread: CGFloat = 0)
    {
        self.shadowColor = color
        self.shadowOpacity = opacity
        self.shadowOffset = CGPoint(x: x, y: y)
        self.shadowBlur = blur
        self.shadowSpread = spread
    }
}

#endif
