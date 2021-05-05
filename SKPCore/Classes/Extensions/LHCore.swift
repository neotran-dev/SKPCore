//
//  LHCore.swift
//  PilldeliBases iOS
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2019 datnm. All rights reserved.
//

import Foundation

public protocol LHCoreProtocol {
    static var name: String { get }
    var name: String { get }
    func errorWith(code: Int, userInfo: [String : Any]?) -> Error
}

public extension LHCoreProtocol {
    static var name: String { return String(describing: self) }
    var name: String { return String(describing: self) }
    func errorWith(code: Int, userInfo: [String : Any]? = nil) -> Error {
        return NSError(domain: self.name, code: code, userInfo: userInfo)
    }
    
    static func errorWith(code: Int, userInfo: [String : Any]? = nil) -> Error {
        return NSError(domain: self.name, code: code, userInfo: userInfo)
    }
}

open class LHCoreBase: LHCoreProtocol {
    
}

open class NSObjectCore: NSObject, LHCoreProtocol {
    
}

public final class LHCoreSDK: LHCoreProtocol { }

/*
/// Type that acts as a generic extension point for all `LHCoreExtended` types.
public struct LHCoreExtension<ExtendedType> {
    /// Stores the type or meta-type of any extended type.
    public private(set) var type: ExtendedType

    /// Create an instance from the provided value.
    ///
    /// - Parameter type: Instance being extended.
    public init(_ type: ExtendedType) {
        self.type = type
    }
}

/// Protocol describing the `api` extension points for Alamofire extended types.
public protocol LHCoreExtended {
    /// Type being extended.
    associatedtype ExtendedType

    /// Static LHCoreSDK extension point.
    static var api: LHCoreExtension<ExtendedType>.Type { get set }
    static var rx: LHCoreExtension<ExtendedType>.Type { get set }
    static var rxRealm: LHCoreExtension<ExtendedType>.Type { get set }
    /// Instance LHCoreSDK extension point.
    var api: LHCoreExtension<ExtendedType> { get set }
    var rx: LHCoreExtension<ExtendedType> { get set }
    var rxRealm: LHCoreExtension<ExtendedType> { get set }
}

public extension LHCoreExtended {
    /// Static LHCoreSDK extension point.
    static var api: LHCoreExtension<Self>.Type {
        get { LHCoreExtension<Self>.self }
        set {}
    }

    /// Instance LHCoreSDK extension point.
    var api: LHCoreExtension<Self> {
        get { LHCoreExtension(self) }
        set {}
    }
    
    /// Static LHCoreSDK extension point.
    static var rx: LHCoreExtension<Self>.Type {
        get { LHCoreExtension<Self>.self }
        set {}
    }

    /// Instance LHCoreSDK extension point.
    var rx: LHCoreExtension<Self> {
        get { LHCoreExtension(self) }
        set {}
    }
    
    /// Static LHCoreSDK extension point.
    static var rxRealm: LHCoreExtension<Self>.Type {
        get { LHCoreExtension<Self>.self }
        set {}
    }

    /// Instance LHCoreSDK extension point.
    var rxRealm: LHCoreExtension<Self> {
        get { LHCoreExtension(self) }
        set {}
    }
}
*/
