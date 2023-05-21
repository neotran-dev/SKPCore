//
//  String++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/2/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
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
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    var isEmptyString: Bool {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""
    }
}

public extension String {
    
    func removeSequencesSpace() -> String {
        var inputString = self
        let whitespaces = CharacterSet.whitespaces
        let parts = inputString.components(separatedBy: whitespaces)
        let filteredArray = parts.filter({ !$0.isEmptyString })
        inputString = filteredArray.joined(separator: " ")
        return inputString
    }
    
    func removeAllWhiteSpace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    func convertToPlainAlphabetical() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func string(withMaximumLength maxLength: Int) -> String? {
        guard length > maxLength else { return self }
        return self.substring(to: maxLength - 1)?.appending("...")
    }
    
    private func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
