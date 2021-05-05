//
//  String++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/2/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation

public extension String {
    
    var deletePrefixPath: String {
        var result = self
        while result.hasPrefix("/") {
            result.removeFirst()
        }
        return result
    }
    
    var deleteSuffixPath: String {
        var result = self
        while result.hasSuffix("/") {
            result.removeLast()
        }
        return result
    }
    
    func isEmptyString() -> Bool {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""
    }
}

public extension String {
    
    func removeSequencesSpace() -> String {
        var inputString = self
        let whitespaces = CharacterSet.whitespaces
        let parts = inputString.components(separatedBy: whitespaces)
        let filteredArray = parts.filter({ !$0.isEmptyString()})
        inputString = filteredArray.joined(separator: " ")
        return inputString
    }
    
    func removeAllWhiteSpace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    func convertToPlainAlphabetical() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
}
