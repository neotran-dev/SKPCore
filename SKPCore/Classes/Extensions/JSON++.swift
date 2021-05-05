//
//  JSON++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/2/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension JSON {
    var dataValue: Data? {
        do {
            let dataParser = try self.rawData()
            return dataParser
        } catch {
            return self.stringValue.data(using: String.Encoding.utf8)
        }
    }
    
    var stringTrimmed: String? { return self.string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
    
    var stringValueTrimmed: String { return self.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
    
    func mergedValues(with other: JSON) -> JSON {
        var merged = self
        do {
            merged = try self.merged(with: other)
        } catch { }
        return merged
    }
    
    mutating func removeItem(_ atIndex: Int) {
        guard self.type == .array else {
            return
        }
        guard self.count > atIndex, atIndex >= 0  else {
            return
        }
        var values = self.arrayValue
        values.remove(at: atIndex)
        self = JSON(values)
    }
    
    mutating func mergeArray(_ json: JSON) {
        guard self.type == .array else {
            self = self.mergedValues(with: json)
            return
        }
        
        do {
            try self.merge(with: json)
        } catch {
            var values = self.arrayValue
            json.array?.forEach({ (item) in
                values.append(item)
            })
            self = JSON(values)
        }
    }
}
