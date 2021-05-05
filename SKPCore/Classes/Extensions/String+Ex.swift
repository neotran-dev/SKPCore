//
//  String+Ex.swift
//  Base Extensions
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

import Foundation
#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import Cocoa
#else
#endif

public extension String {
    var nsString: NSString { return self as NSString }
    var length: Int { return self.nsString.length }
    var trimWhiteSpace: String { return self.trimmingCharacters(in: .whitespaces) }
    var trimWhiteSpaceAndNewLine: String { return self.trimmingCharacters(in: .whitespacesAndNewlines) }
    static let empty: String = ""
    
    func indexOffset(_ by: Int) -> String.Index {
        return self.index(self.startIndex, offsetBy: by)
    }
    
    subscript (index: Int) -> String {
        let indexBy = indexOffset(index)
        guard indexBy < self.endIndex else { return "" }
        return String(self[indexBy])
    }
    
    static func path(withComponents components: [String]) -> String {
        return NSString.path(withComponents: components)
    }
    
    func appendingPathComponent(_ pathComponent: String?) -> String {
        guard let pathComponent = pathComponent else {
            return self
        }
        return (self as NSString).appendingPathComponent(pathComponent)
    }
    
    func appendingPathExtension(_ pathExtension: String?) -> String {
        guard let pathExtension = pathExtension else {
            return self
        }
        return (self as NSString).appendingPathExtension(pathExtension) ?? self
    }
    
    var pathComponents: [String] { return nsString.pathComponents }
    var isAbsolutePath: Bool { return nsString.isAbsolutePath }
    var lastPathComponent: String { return nsString.lastPathComponent }
    var deletingLastPathComponent: String { return nsString.deletingLastPathComponent }
    var pathExtension: String { return nsString.pathExtension }
    var deletingPathExtension: String { return nsString.deletingPathExtension }
    
    func indexOf(target: String) -> Int {
        if let range = self.range(of: target) {
            return self.distance(from: startIndex, to: range.lowerBound)
        }
        return -1
    }
    
    static func isEmpty(_ string: String?, trimCharacters: CharacterSet = CharacterSet(charactersIn: "")) -> Bool {
        if (string == nil) { return true }
        return string!.trimmingCharacters(in: trimCharacters) == ""
    }
    
    func toDate(formatter: DateFormatter) -> Date? {
        return formatter.date(from: self)
    }
    
    func toDate(format dateFormat: String, locale: Locale? = nil, timeZone: TimeZone? = nil) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let locale = locale { dateFormatter.locale = locale }
        if let timeZone = timeZone { dateFormatter.timeZone = timeZone }
        return dateFormatter.date(from: self)
    }
    
    func toDateFormat8601() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
    }
    
    func toDateFormatRFC3339() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: self)
    }
    
    func getDynamicHeight(withFont: NSUIFont) -> CGFloat {
        return self.nsString.size(withAttributes: [NSAttributedString.Key.font: withFont]).height
    }
    
    mutating func stringByDeleteCharactersInRange(_ range: NSRange) {
        let startIndex = self.index(self.startIndex, offsetBy: range.location)
        let endIndex = self.index(startIndex, offsetBy: range.length)
        self.removeSubrange(startIndex ..< endIndex)
    }
    
    func stringByDeletePrefix(_ prefix: String?) -> String {
        if let prefixString = prefix, self.hasPrefix(prefixString) {
            return self.nsString.substring(from: prefixString.length)
        }
        return self
    }
    
    func stringByDeleteSuffix(_ suffix: String?) -> String {
        if let suffixString = suffix, self.hasSuffix(suffixString) {
            return self.nsString.substring(to: self.length - suffixString.length)
        }
        return self
    }
    
    func deleteSuffix(_ suffix: Int) -> String {
        if suffix >= self.length {
            return self
        }
        return self.nsString.substring(to: self.length - suffix)
    }
    
    func deleteSub(_ subStringToDelete: String) -> String {
        return self.replacingOccurrences(of: subStringToDelete, with: "")
    }
    
    func getRanges(of: String?) -> [NSRange]? {
        guard let ofString = of, String.isEmpty(ofString) == false else {
            return nil
        }
        
        do {
            let regex = try NSRegularExpression(pattern: ofString)
            return regex.matches(in: self, range: NSRange(location: 0, length: self.length)).map({ (textCheckingResult) -> NSRange in
                return textCheckingResult.range
            })
        } catch {
            let range = self.nsString.range(of: ofString)
            if range.location != NSNotFound {
                var ranges = [NSRange]()
                ranges.append(range)
                let remainString = self.nsString.substring(from: range.location + range.length)
                if let rangesNext = remainString.getRanges(of: ofString) {
                    ranges.append(contentsOf: rangesNext)
                }
                return ranges
            } else {
                return nil
            }
        }
    }
    
    func rangesOfString(_ ofString: String, options: NSString.CompareOptions = [], searchRange: Range<Index>? = nil ) -> [Range<Index>] {
        if let range = self.range(of: ofString, options: options, range: searchRange, locale: nil) {
            let nextRange: Range = range.upperBound..<self.endIndex
            return [range] + rangesOfString(ofString, searchRange: nextRange)
        }
        return []
    }
    
    func addSpaces(_ forMaxLenght: Int) -> String {
        if self.length >= forMaxLenght { return self }
        var result = self
        for _ in 0..<(forMaxLenght - self.length) {
            result.append(" ")
        }
        return result
    }
    
    var int: Int? { return Int(self.deleteSub(",")) }
    var int64: Int64? { return Int64(self.deleteSub(",")) }
    var intValue: Int { return Int(self.deleteSub(",")) ?? 0 }
    var int64Value: Int64 { return Int64(self.deleteSub(",")) ?? 0 }
    
    @discardableResult
    func writeToDocument(_ fileName: String) -> Bool {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            //writing
            do {
                try self.write(to: fileURL, atomically: false, encoding: .utf8)
                return true
            } catch { /* error handling here */ }
        }
        return false
    }
    
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
    func isValidWithRegex(_ regex: String) -> Bool {
        return self ~= regex
    }
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        return isValidWithRegex(emailRegex)
    }
    
    var isValidPhone: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    var isValidUrl: Bool {
        guard let url = URL(string: self) else { return false }
        return !String.isEmpty(url.scheme) && !String.isEmpty(url.host)
    }
    
    var encodeUrlPercentEncoding: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    var localizedString: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func substring(from: Int) -> String? {
        guard from >= 0 else { return nil }
        return nsString.substring(from: from)
    }
    
    func substring(to: Int) -> String? {
        guard to >= 0, to < nsString.length else { return nil }
        return nsString.substring(to: to)
    }
    
    func substring(from: Int, to: Int) -> String? {
        guard from >= 0, to >= 0, to > from, to <= nsString.length else { return nil }
        return nsString.substring(with: NSMakeRange(from, to - from))
    }
    
    var parseQuery: [String: String] {
        var query = [String: String]()
        let pairs = self.components(separatedBy: "&")
        for pair in pairs {
            let elements = pair.components(separatedBy: "=")
            if elements.count == 2 {
                let qKey = elements[0].removingPercentEncoding ?? elements[0]
                let qValue = elements[1].removingPercentEncoding ?? elements[1]
                query[qKey] = qValue
            }
        }
        return query
    }
    
    func encodeUrl(_ characterSet: CharacterSet = .urlFragmentAllowed) -> String {
        return self.addingPercentEncoding(withAllowedCharacters: characterSet) ?? self
    }
    
    var toURL: URL? { return URL(string: self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) }
    func toURL(trimmingCharacters: CharacterSet = .whitespacesAndNewlines, percentEncoding: CharacterSet? = .urlFragmentAllowed) -> URL? {
        var urlStr = self.trimmingCharacters(in: trimmingCharacters)
        if let percent = percentEncoding { urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: percent) ?? urlStr }
        return URL(string: urlStr)
    }
}

public extension NSMutableAttributedString {
    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        self.addAttribute(name, value: value, range: NSRange(location: 0, length: self.string.length))
    }
    
    func setFont(_ font: NSUIFont, atRange: NSRange) {
        self.addAttributes([NSAttributedString.Key.font: font], range: atRange)
    }
    
    func setTextColor(_ color: NSUIColor, atRange: NSRange) {
        self.addAttributes([NSAttributedString.Key.foregroundColor: color], range: atRange)
    }
    
    func setFont(_ font: NSUIFont, for subString: String?) {
        guard let forSubString = subString, String.isEmpty(forSubString) == false else { return }
        let rangeOfSub = self.string.nsString.range(of: forSubString)
        if rangeOfSub.location != NSNotFound {
            self.addAttributes([NSAttributedString.Key.font: font], range: rangeOfSub)
        } else {
            // not proccess
        }
    }
    
    func setTextColor(_ color: NSUIColor, for subString: String?) {
        guard let forSubString = subString, String.isEmpty(forSubString) == false else { return }
        let rangeOfSub = self.string.nsString.range(of: forSubString)
        if rangeOfSub.location != NSNotFound {
            self.addAttributes([NSAttributedString.Key.foregroundColor: color], range: rangeOfSub)
        } else {
            // not proccess
        }
    }
    
    func setFont(_ font: NSUIFont, forSubs subString: String?) {
        self.string.getRanges(of: subString)?.forEach({ (range) in
            if range.location != NSNotFound {
                self.addAttributes([NSAttributedString.Key.font: font], range: range)
            } else {
                // not proccess
            }
        })
    }
    
    func setTextColor(_ color: NSUIColor, forSubs subString: String?) {
        self.string.getRanges(of: subString)?.forEach({ (range) in
            if range.location != NSNotFound {
                self.addAttributes([NSAttributedString.Key.foregroundColor: color], range: range)
            } else {
                // not proccess
            }
        })
    }
    
    @discardableResult
    func append(_ string: String, attributes: [NSAttributedString.Key : Any]? = nil) -> NSMutableAttributedString {
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    @discardableResult
    func append(_ string: String, font: NSUIFont, textColor: NSUIColor? = nil) -> NSMutableAttributedString {
        var attributes = [NSAttributedString.Key : Any]()
        attributes[.font] = font
        if let textColor = textColor { attributes[.foregroundColor] = textColor }
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func setFont(_ font: NSUIFont) {
        self.setFont(font, for: self.string)
    }
    
    func setTextColor(_ color: NSUIColor) {
        self.setTextColor(color, for: self.string)
    }
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties else {
            return false
        }
        if #available(iOS 10.2, *) {
            return unicodeScalars.count == 1 && (firstProperties.isEmojiPresentation
                || firstProperties.generalCategory == .otherSymbol)
        } else {
            // Fallback on earlier versions
            for scalar in unicodeScalars {
                switch scalar.value {
                case 0x1F600...0x1F64F, // Emoticons
                     0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                     0x1F680...0x1F6FF, // Transport and Map
                     0x2600...0x26FF,   // Misc symbols
                     0x2700...0x27BF,   // Dingbats
                     0xFE00...0xFE0F:   // Variation Selectors
                    return true
                default:
                    continue
                }
            }
            return false
        }
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        if #available(OSX 10.12.2, iOS 10.2, *) {
            return (unicodeScalars.count > 1 && unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector })
                || unicodeScalars.allSatisfy({ $0.properties.isEmojiPresentation })
        } else {
           // Fallback on earlier versions
           for scalar in unicodeScalars {
               switch scalar.value {
               case 0x1F600...0x1F64F, // Emoticons
                    0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                    0x1F680...0x1F6FF, // Transport and Map
                    0x2600...0x26FF,   // Misc symbols
                    0x2700...0x27BF,   // Dingbats
                    0xFE00...0xFE0F:   // Variation Selectors
                   return true
               default:
                   continue
               }
           }
           return false
        }
    }

    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}

extension String {
    var isSingleEmoji: Bool {
        return count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        return contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains { !$0.isEmoji }
    }

    var emojiString: String {
        return emojis.map { String($0) }.reduce("", +)
    }

    var emojis: [Character] {
        return filter { $0.isEmoji }
    }

    var emojiScalars: [UnicodeScalar] {
        return filter{ $0.isEmoji }.flatMap { $0.unicodeScalars }
    }
}

public extension URLComponents {
    func queries(lowercaseName: Bool = true) -> [String: String] {
        guard let qis = queryItems else { return [:] }
        var result: [String: String] = [:]
        for qi in qis {
            result[lowercaseName ? qi.name.lowercased() : qi.name] = qi.value ?? ""
        }
        return result
    }
}

public extension URL {
    func queries(componentsResolvingAgainstBaseURL resolve: Bool = false, lowercaseName: Bool = true) -> [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: resolve) else { return [:] }
        return components.queries(lowercaseName: lowercaseName)
    }
    
    init?(string: String?, percentEncoding: CharacterSet? = .urlFragmentAllowed) {
        var urlStr = string
        if let percent = percentEncoding { urlStr = string?.addingPercentEncoding(withAllowedCharacters: percent) }
        guard let str = urlStr else { return nil }
        self.init(string: str)
    }
}

public extension URLRequest {
    init(url: URL, headers: [String: String]?) {
        self.init(url: url)
        headers?.forEach({ (header) in
            self.addValue(header.value, forHTTPHeaderField: header.key)
        })
    }
}
