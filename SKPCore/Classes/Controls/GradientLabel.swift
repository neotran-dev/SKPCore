//
//  GradientLabel.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 12/9/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation
import UIKit

public class GradientLabel: UILabel {
    
    public var gradientColors = [UIColor(rgb: 0xf5505c).cgColor, UIColor(rgb: 0xdd60a3).cgColor, UIColor(rgb: 0xc571eb).cgColor, UIColor(rgb: 0x6a9aeb).cgColor, UIColor(rgb: 0x1bbee9).cgColor] {
        didSet {
            self.setNeedsDisplay()
            self.setup()
        }
    }
    
    public var lineWidth: CGFloat = 10 {
        didSet {
            self.setup()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        self.textAlignment = .center
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors =  gradientColors
        
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.layer.addSublayer(gradient)
    }
    
    public override func drawText(in rect: CGRect) {
        setup()
        if let gradientColor = drawGradientColor(in: rect, colors: gradientColors) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
    }
    
    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }
        
        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: nil) else { return nil }
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: CGPoint.zero,
                                    end: CGPoint(x: size.width, y: 0),
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
    
}
