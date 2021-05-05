//
//  UtilsEx.swift
//  Base Extensions
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

import Foundation

/** This file provides a thin abstraction layer atop of UIKit (iOS, tvOS) and Cocoa (OS X). The two APIs are very much
 alike, and for the chart library's usage of the APIs it is often sufficient to typealias one to the other. The NSUI*
 types are aliased to either their UI* implementation (on iOS) or their NS* implementation (on OS X). */
#if os(iOS) || os(tvOS)
#if canImport(UIKit)
    import UIKit
#endif

public typealias NSUIFont = UIFont
public typealias NSUIImage = UIImage
public typealias NSUIApplication = UIApplication
public typealias NSUIScreen = UIScreen
public typealias NSUIView = UIView
public typealias NSUIViewController = UIViewController
public typealias NSUIEdgeInsets = UIEdgeInsets
public typealias NSUIColor = UIColor
public typealias NSUINib = UINib
public typealias NSUIBezierPath = UIBezierPath
#endif

#if os(OSX)
#if canImport(Cocoa)
    import Cocoa
#endif

public typealias NSUIFont = NSFont
public typealias NSUIImage = NSImage
public typealias NSUIApplication = NSApplication
public typealias NSUIScreen = NSScreen
public typealias NSUIView = NSView
public typealias NSUIViewController = NSViewController
public typealias NSUIEdgeInsets = NSEdgeInsets
public typealias NSUIColor = NSColor
public typealias NSUINib = NSNib
public typealias NSUIBezierPath = NSBezierPath
#endif


public func DebugLogFull(_ items: Any..., separator: String = " ", terminator: String = "\n", filePath: StaticString = #file, function: StaticString = #function, line: Int = #line)
{
    #if DEBUG
    let formatDate = DateFormatter();
    formatDate.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let time = formatDate.string(from: Date())
    let filename = "\(filePath)".lastPathComponent
    let funcName = "\(function)".components(separatedBy: "(").first ?? "\(function)"
    var message = "\(time) [\(filename):\(line)]|\(funcName)->\n-> "
    for index in 0..<items.endIndex {
        print(items[index], separator: separator, terminator: separator, to: &message)
    }
    print(message.stringByDeleteSuffix(separator))
    #endif
}

public func DebugLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    // to use this, you must sure that: "-D DEBUG added to "Other Swift Flags" in your target's Build Settings at Debug mode

    #if DEBUG
    let formatDate = DateFormatter()
    formatDate.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let time = formatDate.string(from: Date())
    var message = "\(time) "

    for index in 0..<items.endIndex {
        print(items[index], separator: separator, terminator: separator, to: &message)
    }
    print(message.stringByDeleteSuffix(separator))
    #endif
}

public func LocalizedString(_ key: String, tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", comment: String = "") -> String {
    return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
}

public extension NSObject {
    var description: String { return String(describing: self) }
}

public extension UserDefaults {
    static func setObj(_ value: Any?, forKey: String) {
        standard.set(value, forKey: forKey)
        standard.synchronize()
    }

    static func setInt(_ value: Int, forKey: String) {
        standard.set(value, forKey: forKey)
        standard.synchronize()
    }

    /// -setFloat:forKey: is equivalent to -setObject:forKey: except that the value is converted from a float to an NSNumber.
    static func setFloat(_ value: Float, forKey: String) {
        standard.set(value, forKey: forKey)
        standard.synchronize()
    }

    /// -setDouble:forKey: is equivalent to -setObject:forKey: except that the value is converted from a double to an NSNumber.
    static func setDouble(_ value: Double, forKey: String) {
        standard.set(value, forKey: forKey)
        standard.synchronize()
    }

    /// -setBool:forKey: is equivalent to -setObject:forKey: except that the value is converted from a BOOL to an NSNumber.
    static func setBool(_ value: Bool, forKey: String) {
        standard.set(value, forKey: forKey)
        standard.synchronize()
    }

    static func objectForKey(_ forKey: String) -> Any? {
        return standard.value(forKey: forKey)
    }

    static func intForKey(_ forKey: String) -> Int {
        return standard.integer(forKey: forKey)
    }

    /// -setFloat:forKey: is equivalent to -setObject:forKey: except that the value is converted from a float to an NSNumber.
    static func floatForKey(_ forKey: String) -> Float {
        return standard.float(forKey: forKey)
    }

    /// -setDouble:forKey: is equivalent to -setObject:forKey: except that the value is converted from a double to an NSNumber.
    static func doubleForKey(_ forKey: String) -> Double {
        return standard.double(forKey: forKey)
    }

    /// -setBool:forKey: is equivalent to -setObject:forKey: except that the value is converted from a BOOL to an NSNumber.
    static func boolForKey(_ forKey: String) -> Bool {
        return standard.bool(forKey: forKey)
    }
    
    static func removeObjectForKey(_ forKey: String) {
        standard.removeObject(forKey: forKey)
    }

    /// -stringForKey: is equivalent to -objectForKey:, except that it will convert NSNumber values to their NSString representation. If a non-string non-number value is found, nil will be returned.
    static func stringForKey(_ forKey: String) -> String? {
        return standard.string(forKey: forKey)
    }
    
    /// -arrayForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray.
    static func arrayForKey(_ forKey: String) -> [Any]? {
        return standard.array(forKey: forKey)
    }
    
    /// -dictionaryForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSDictionary.
    static func dictionaryForKey(_ forKey: String) -> [String : Any]? {
        return standard.dictionary(forKey: forKey)
    }
    
    /// -dataForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSData.
    static func dataForKey(_ forKey: String) -> Data? {
        return standard.data(forKey: forKey)
    }
    
    /// -stringForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray<NSString *>. Note that unlike -stringForKey:, NSNumbers are not converted to NSStrings.
    static func stringArrayForKey(_ forKey: String) -> [String]? {
        return standard.stringArray(forKey: forKey)
    }
    
    static func registerDefaults(_ defaults: [String: Any]) {
        var df = [String: Any]()
        defaults.forEach { (item) in
            df[item.key] = item.value
        }
        standard.register(defaults: df)
        standard.synchronize()
    }
}

public extension LHCoreSDK {
    final class AssociatedObject {
        public static func get<T>(_ object: Any?, _ key: UnsafeRawPointer, defaultValue: T? = nil) -> T? {
            guard let obj = object else { return nil }
            return (objc_getAssociatedObject(obj, key) as? T) ?? defaultValue
        }
        
        public static func set<T>(_ object: Any?, _ key: UnsafeRawPointer, value: T? = nil, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
            guard let obj = object else { return }
            objc_setAssociatedObject(obj, key, value, policy)
        }
    }
}
