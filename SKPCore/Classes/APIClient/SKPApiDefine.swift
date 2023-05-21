//
//  Define.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/2/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

public typealias SKPApiUploadProgressHandler = (Int64, TimeInterval?) -> Void
public typealias SKPApiCompletionHandler = (JSON, Error?) -> Void

public struct SKPMultipartData {
    public var data: Data
    public var name: String
    public var fileExtension: String
    public var mimeType: String = "image/jpeg"
    
    public init(data dataE: Data, name nameE: String, fileExtension ext: String = "jpeg", mimeType mime: String = "image/jpeg") {
        self.data = dataE
        self.name = nameE
        self.fileExtension = ext
        self.mimeType = mime
    }
}

public enum SKPApiPreRequestState {
    case ready
    case needRefreshToken
    case needAuthen
}

public enum SKPApiRequestState {
    case normal
    case begin
    case success
    case error(message: String)
}

public enum SKPAuthorization: Equatable {
    case token(token: String, isBearer: Bool)
    case basic(username: String, password: String)
    case none
    
    var headerValue: [String: String] {
        switch self {
        case .token(let token, let isBearer):
            if isBearer {
                return ["Authorization": "Bearer \(token)"]
            } else {
                return ["Authorization": "\(token)"]
            }
        case .basic(let username, let password):
            let credentialData = "\(username):\(password)".data(using: .utf8)
            
            guard let cred = credentialData else { return [:] }
            let base64Credentials = cred.base64EncodedData(options: [])
            guard let base64Date = Data(base64Encoded: base64Credentials) else { return [:] }
            return ["Authorization": "Basic \(base64Date.base64EncodedString())"]
            
        default:
            return [:]
        }
    }
}
