//
//  DataResponse++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/2/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public extension DataResponse {
    
    var errorResponse: Error? {
        guard let mError = self.error as NSError? else { return nil }
        return errorResponseWithError(mError)
    }
    
    func errorResponseWithError(_ error: Error) -> Error {
        
        guard let dataRes = self.data else { return error.nsError }
        
        let statusCode = self.response?.statusCode ?? error.code
        
        do {
            let jsonRes = try JSON(data: dataRes, options: .allowFragments)
            
            var userInfo = error.userInfo
            
            if let obj = jsonRes.dictionaryObject {
                userInfo["responseData"] = obj
            } else if let resString = jsonRes.rawString() {
                userInfo["responseData"] = resString
            }
            return NSError(domain: error.domain, code: statusCode, userInfo: userInfo)
        } catch {
            guard let dataRes = self.data,
                let resString = String(data: dataRes, encoding: String.Encoding.utf8) else {
                    return NSError(domain: error.domain, code: statusCode, userInfo: error.userInfo)
            }
            var userInfo = error.userInfo
            userInfo["responseData"] = resString
            return NSError(domain: error.domain, code: statusCode, userInfo: userInfo)
        }
    }
}
