//
//  UIColor+Ex.swift
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

public extension NSUIColor {
    /**
     The six-digit hexadecimal representation of color of the form #RRGGBB.
     - parameter hex6: Six-digit hexadecimal value.
     */
    convenience init(hexCss rgb: UInt32, alpha alph: CGFloat = 1.0) {
        let red = CGFloat((rgb & 0xFF0000) >> 16) / CGFloat(255)
        let green = CGFloat((rgb & 0x00FF00) >> 8) / CGFloat(255)
        let blue = CGFloat( rgb & 0x0000FF) / CGFloat(255)
        self.init(red: red, green: green, blue: blue, alpha: alph)
    }
    
    #if os(iOS) || os(tvOS)
    func toImage(_ size: CGSize = CGSize(width: 8, height: 8)) -> UIImage? {
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size: size).image { (rendererContext) in
                self.setFill()
                rendererContext.fill(CGRect(origin: .zero, size: size))
            }
        } else {
            // Fallback on earlier versions
            let rect = CGRect(origin: CGPoint.zero, size: size)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            self.setFill()
            UIRectFill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    #endif
}
