//
//  Error++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/2/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation

public enum HTTPError: Error {
    case badRequest // 400
    case unauthorized // 401
    case forbidden // 403
    case notFound // 404
    case conflict // 409
    case internalServer // 500
    
    public var description: String? {
        switch self {
        case .badRequest: return "Bad Request Error"
        case .unauthorized: return "Unauthorized Error"
        case .forbidden: return "Forbiden Error"
        case .notFound: return "Not Found"
        case .conflict: return "Conflict"
        case .internalServer: return "Internal Error"
        }
    }
    
    public var code: Int? {
        switch self {
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .conflict: return 409
        case .internalServer: return 500
        }
    }
}

public extension Error {
    var nsError: NSError { return self as NSError }
    
    var domain: String { return nsError.domain }
    
    var code: Int { return nsError.code }
    
    var userInfo: [String: Any] { return nsError.userInfo }
    
    var isUnauthorizedError: Bool { return self.code == HTTPError.unauthorized.code }
    
    var isForbidden: Bool { return self.code == HTTPError.forbidden.code }
    
    var isNotFound: Bool { return  self.code == HTTPError.notFound.code }
    
    var isForbiddenOrNotFound: Bool { return self.isForbidden || self.isNotFound }
    
    var message: String {
        guard let data  = (self.userInfo["responseData"] as? [String: Any]) else {
            return self.localizedDescription
        }
        return (data["error"] as? String) ?? (data["message"] as? String) ?? self.localizedDescription
    }
}
