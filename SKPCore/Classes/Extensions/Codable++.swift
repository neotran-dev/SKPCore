//
//  Codable++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 07/12/2021.
//

import Foundation

public extension Encodable {
    
    func toString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toJson() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}
