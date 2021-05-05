//
//  Collection+Ex.swift
//  Skeleton-MVVM-RxSwift
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

import Foundation

public extension Array where Element: Hashable {
    // same as Distinct()
    // arrs = ["four","one", "two", "one", "three","four", "four"]
    // arrs.unique => ["four", "one", "two", "three"]
    var unique: [Element] {
        var alreadyAdded = Set<Iterator.Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
}

public extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    @discardableResult
    mutating func remove(object: Element) -> Int? {
        if let index = firstIndex(of: object) {
            remove(at: index)
            return index
        }

        return nil
    }

    func indexOf(object: Element) -> Int? {
        guard (self as NSArray).contains(object) else { return nil }
        return (self as NSArray).index(of: object)
    }

    @discardableResult
    mutating func removeFirstSafe() -> Element? {
        guard self.count > 0 else { return nil }
        return self.removeFirst()
    }

    @discardableResult
    mutating func removeLastSafe() -> Element? {
        guard self.count > 0 else { return nil }
        return self.removeLast()
    }
}

public extension Array where Element: StringProtocol {
    var filterEmpty: [Element] {
        return self.filter({ (item) -> Bool in
            return !item.isEmpty
        })
    }
}

public extension Array {
    var customDescription: String {
        guard !isEmpty else { return "[]" }
        var result = "\(type(of: self))[\(count)]=["
        for (i, e) in enumerated() {
            result += "\n\t·\(i)=\(e)"
        }
        result += "\n]"
        return result
    }
}

public extension Dictionary {
    var customDescription: String {
        guard !isEmpty else { return "[]" }
        var result = "\(type(of: self))[\(count)]=["
        for k in keys {
            if let v = self[k] {
                result += "\n\t·\(k)=\(v)"
            } else {
                result += "\n\t·\(k)=nil"
            }
        }
        result += "\n]"
        return result
    }
}

public extension Dictionary {
    static func += (lhs: inout [Key:Value], rhs: [Key:Value]) {
        lhs.merge(rhs){$1}
    }
    static func + (lhs: [Key:Value], rhs: [Key:Value]) -> [Key:Value] {
        return lhs.merging(rhs){$1}
    }
    
    @discardableResult
    mutating func addEntries(from other: [Key: Value]?) -> [Key: Value] {
        guard let other = other, other.count > 0 else { return self }
        
        for (key, value) in other {
            self[key] = value
        }
        
        return self
    }
    
    @discardableResult
    mutating func removeValues(forKeys keyArray: [Key]) -> [Key: Value] {
        for key in keyArray {
            self.removeValue(forKey: key)
        }
        return self
    }

    @discardableResult
    mutating func setDictionary(_ otherDictionary: [Key: Value]) -> [Key: Value] {
        self = otherDictionary
        return self
    }
}

public extension Dictionary where Key: Comparable {
    var customDescription: String {
        guard !isEmpty else { return "[]" }
        var result = "\(type(of: self))[\(count)]=["
        for k in keys.sorted() {
            if let v = self[k] {
                result += "\n\t·\(k)=\(v)"
            } else {
                result += "\n\t·\(k)=nil"
            }
        }
        result += "\n]"
        return result
    }
}

public extension IndexPath {
    #if os(iOS) || os(tvOS)
    static func rows(_ rows: [Int], section: Int = 0) -> [Self] {
        rows.map { .init(row: $0, section: section) }
    }

    static func rows(_ args: Int..., section: Int = 0) -> [Self] {
        rows(args, section: section)
    }
    #endif
    static func items(_ items: [Int], section: Int = 0) -> [Self] {
        items.map { .init(item: $0, section: section) }
    }

    static func items(_ args: Int..., section: Int = 0) -> [Self] {
        items(args, section: section)
    }
}

public extension Optional {
    var wrappedDescription: String {
        guard let wrapped = self else { return "nil" }
        return "\(wrapped)"
    }
}

public extension Optional where Wrapped: Collection {
    var isEmpty: Bool {
        guard let wrapped = self else { return true }
        return wrapped.isEmpty
    }
    
    var countValue: Int {
        return self?.count ?? 0
    }
}
