//
//  UIImage+Gif.swift
//  LHCoreExtensions iOS
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
#if canImport(UIKit)
    import UIKit
    import MobileCoreServices
#endif

import ImageIO

extension UIImageView {

    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

extension UIImage {
    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }

        return gif(data: dataAsset.data)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!

            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        // Fill arrays
        for index in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
        }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for index in 0..<count {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)

        return animation
    }
    
    public func animatedImageByScalingAndCropping(to size: CGSize) -> UIImage? {
        guard !self.size.equalTo(size) &&
                !size.equalTo(CGSize.zero) else {
            return self
        }
        
        guard let images = self.images else {
            return self.imageWith(newSize: size)
        }

        var scaledSize = size
        var thumbnailPoint = CGPoint.zero

        let widthFactor = size.width / self.size.width
        let heightFactor = size.height / self.size.height
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (size.height - scaledSize.height) * 0.5
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (size.width - scaledSize.width) * 0.5
        }
        
        var scaledImages: [UIImage] = []

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        for image in images {
            image.draw(in: CGRect(x: thumbnailPoint.x, y: thumbnailPoint.y, width: scaledSize.width, height: scaledSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()

            if let newImage = newImage {
                scaledImages.append(newImage)
            }
        }

        UIGraphicsEndImageContext()

        return UIImage.animatedImage(with: scaledImages, duration: duration)
    }
    
    public func gifDataRepresentation(gifDuration: TimeInterval = 0.0, loopCount: Int = 0) throws -> Data {
        let images = self.images ?? [self]
        let frameCount = images.count
        let frameDuration: TimeInterval = gifDuration <= 0.0 ? self.duration / Double(frameCount) : gifDuration / Double(frameCount)
        let frameDelayCentiseconds = Int(lrint(frameDuration * 100))
        let frameProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: NSNumber(value: frameDelayCentiseconds)
            ]
        ]

        guard let mutableData = CFDataCreateMutable(nil, 0),
           let destination = CGImageDestinationCreateWithData(mutableData, kUTTypeGIF, frameCount, nil) else {
            throw NSError(domain: "AnimatedGIFSerializationErrorDomain",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Could not create destination with data."])
        }
        let imageProperties = [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: NSNumber(value: loopCount)]
        ] as CFDictionary
        CGImageDestinationSetProperties(destination, imageProperties)
        for image in images {
            if let cgimage = image.cgImage {
                CGImageDestinationAddImage(destination, cgimage, frameProperties as CFDictionary)
            }
        }

        let success = CGImageDestinationFinalize(destination)
        if !success {
            throw NSError(domain: "AnimatedGIFSerializationErrorDomain",
                          code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "Could not finalize image destination"])
        }
        return mutableData as Data
    }
}

#endif
