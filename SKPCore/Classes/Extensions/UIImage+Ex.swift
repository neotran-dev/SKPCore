//
//  UIImage+Ex.swift
//  Base Extensions
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
    import Cocoa
#endif

public extension NSUIImage {
    convenience init?(named: String, ofType: String? = "png", inBundle: Bundle? = Bundle.main) {
        guard let path = (inBundle ?? Bundle.main).path(forResource: named, ofType: ofType) else { return nil }
        self.init(contentsOfFile: path)
    }
    
    func maskColor(_ color: NSUIColor?) -> NSUIImage {
        guard let color = color else { return self }
        var resultImage = self
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        if let context = UIGraphicsGetCurrentContext() {
            let rect = CGRect(origin: CGPoint.zero, size: size)
            color.setFill()
            self.draw(in: rect)
            context.setBlendMode(.sourceIn)
            context.fill(rect)

            if let imgContext = UIGraphicsGetImageFromCurrentImageContext() { resultImage = imgContext }
        }
        UIGraphicsEndImageContext()

        return resultImage
    }

    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func resizeCentered() -> UIImage {
        let vCap = size.height / 2
        let hCap = size.width / 2
        return resizableImage(withCapInsets: .init(top: vCap, left: hCap, bottom: vCap, right: hCap))
    }

    var scaledSize: CGSize {
        .init(width: size.width * scale, height: size.height * scale)
    }
    
    func size(withLimitedSize limitedSize: CGSize) -> CGSize {
        let originalSize = self.size
        var thumbSize = originalSize
        if originalSize.width > limitedSize.width {
            thumbSize.width = limitedSize.width
            thumbSize.height = originalSize.height / (1.0 * (originalSize.width / thumbSize.width))
        }
        if originalSize.height > limitedSize.height {
            thumbSize.height = limitedSize.height
            thumbSize.width = originalSize.width / (1.0 * (originalSize.height / thumbSize.height))
        }
        return thumbSize
    }
    
    func imageWith(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: newSize
            ))
        }
        return scaledImage
    }
}
#endif
