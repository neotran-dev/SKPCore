//
//  Codable.Mapper.swift
//  LHCoreSDK
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

import Foundation

public protocol TransformType {
    associatedtype Object
    associatedtype JSON: Decodable
  
    func transform(_ value: JSON?) -> Object?
}

public struct DateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public var formatter: DateFormatter = DateFormatter()
    
    public init(_ format: String = "yyyy/MM/dd HH:mm:ss Z", calendar: Calendar? = nil, timeZone: TimeZone? = nil) {
        formatter.dateFormat = format
        formatter.calendar = calendar
        formatter.timeZone = timeZone
    }
  
    public func transform(_ value: String?) -> Date? {
        guard let value = value else { return nil }
        return formatter.date(from: value)
    }
}

precedencegroup Base {
    associativity: left
    lowerThan: AdditionPrecedence
}

infix operator <- : Base

public func <- <T: Decodable>(left: inout T, right: T?) {
    left = right ?? left
}

public func <- <Transform: TransformType>(left: inout Transform.Object, right: (Transform.JSON?, Transform)) {
    left = right.1.transform(right.0) ?? left
}

public func <- <Transform: TransformType>(left: inout Transform.Object?, right: (Transform.JSON?, Transform)) {
    left = right.1.transform(right.0) ?? left
}

struct ContainerKey: CodingKey {
    var stringValue: String = ""
    var intValue: Int? = nil
  
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
  
    init?(intValue: Int) {
        self.intValue = intValue
    }
}

extension Decoder {
    public subscript<T: Decodable>(key: String) -> T? {
        get {
            return Self.decode(self, key: key)
        }
    }
  
    static func decode<T: Decodable>(_ decorder: Decoder, key: String) -> T? {
        guard let container = try? decorder.container(keyedBy: ContainerKey.self) else { return nil }
        let keys = key.components(separatedBy: ".")
        if keys.count == 1 {
            guard let containerKey = ContainerKey(stringValue: key) else { return nil }
            guard let value = try? container.decode(T.self, forKey: containerKey) else { return nil }
            return value
        } else {
            guard let rootKey = keys.first, let containerKey = ContainerKey(stringValue: rootKey) else { return nil }
            let otherKey = keys.dropFirst().joined(separator: ".")
            guard let superContainer = try? container.superDecoder(forKey: containerKey) else { return nil }
            guard let value: T? = decode(superContainer, key: otherKey) else { return nil }
            return value
        }
    }
}

extension Decodable {
    public init?(JSONString: String) {
        guard let data = JSONString.data(using: .utf8),
            let obj: Self = try? JSONDecoder().decode(Self.self, from: data) else {
                return nil
        }
        
        self = obj
    }
}

/*
 Example:
 
 {
     "id": 100,
     "date": "2015/03/04 12:34:56 +09:00"
 }
 
 struct ContentModel: Decodable {
   var id: Int = 0
   var date: Date?
   
   public init(from decoder: Decoder) throws {
     id <- decoder["id"]
     date <- (decoder["date"], DateTransform())
   }
 }
 
 let contentModel = ContentModel(JSONString: json)!
 */

/*
 Nested value
 nested json to flat.

 {
     "user": {
         "id": 100
     }
 }
 struct User: Decodable {
   var id: Int = 0
   
   public init(from decoder: Decoder) throws {
     id <- decoder["user.id"]
   }
 }
 */
