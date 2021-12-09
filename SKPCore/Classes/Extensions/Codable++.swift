//
//  Codable++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 07/12/2021.
//

import Foundation

public extension Encodable {
    func toJson() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}
