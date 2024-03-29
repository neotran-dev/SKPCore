//
//  SKPApiClient.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 6/2/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON
import KRProgressHUD

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias JSON = SwiftyJSON.JSON
public typealias AFDataResponse = Alamofire.AFDataResponse

final class Logger: EventMonitor {
    let queue = DispatchQueue(label: "AlamofireQueue")
    
    // Event called when any type of Request is resumed.
    func requestDidResume(_ request: Request) {
        print("Resuming: \(request)")
    }
    
    // Event called whenever a DataRequest has parsed a response.
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        // debugPrint("Finished: \(response)")
    }
    
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        if let body = urlRequest.httpBody {
            let str = String(decoding: body, as: UTF8.self)
            debugPrint("Param: \(str)")
        }
        debugPrint("Header: \(urlRequest.allHTTPHeaderFields ?? [String: Any]())")
    }
}

open class SKPApiClient {
    public static var shared: SKPApiClient = SKPApiClient()
    public var baseURL: String = ""
    public var defaultHeaders: [String: String] = [:]
    
    fileprivate var session: Session
    
    public init() {
        session = Session(eventMonitors: [Logger()])
    }
    //MARK: Public Methods
    open func processResponse(_ response: AFDataResponse<Any>, autoCatchError: Bool, completion: SKPApiCompletionHandler?) {
        switch response.result {
        case .success(let resultData):
            completion?(JSON(resultData), nil)
        case .failure(let error):
            let resError = response.errorResponseWithError(error)
            if autoCatchError {
                SKPPopupManager.shared.showErrorAlert(withMessage: resError.message)
                completion?(JSON(), nil)
                return
            }
            completion?(JSON(), resError)
        }
    }
    
    @discardableResult
    open func request(method: HTTPMethod = .get,
                 apiPath: String, params: [String: Any]? = nil,
                 headers: [String: String]? = nil,
                 authorization: SKPAuthorization,
                 showHUD: Bool = true,
                 autoCatchError: Bool = true,
                 completion: SKPApiCompletionHandler? = nil) -> DataRequest {
        
        if showHUD { SKPHUDManager.shared.show() }
        let fullPath = self.buildApiFullPath(apiPath)
        let dataRequest = request(method: method, apiPath: fullPath, params: params, headers: headers, authorization: authorization)
        
        dataRequest.responseJSON { [weak self] dataResponse in
            guard showHUD else {
                self?.processResponse(dataResponse, autoCatchError: autoCatchError, completion: completion)
                return
            }
            SKPHUDManager.shared.dismiss {
                self?.processResponse(dataResponse, autoCatchError: autoCatchError, completion: completion)
            }
        }
        return dataRequest
    }
    
    open func uploadWith(apiPath: String,
                    params: [String: Any]? = nil,
                    headers: [String: String]? = nil,
                    multipartDatas: [SKPMultipartData],
                    authorization: SKPAuthorization,
                    progress: SKPApiUploadProgressHandler? = nil,
                    completion: SKPApiCompletionHandler? = nil) {
        upload(apiPath: apiPath, params: params, headers: headers, multipartDatas: multipartDatas, authorization: authorization, progress: progress, completion: completion)
    }
    
    open func rx_request(
        method: HTTPMethod = .get,
        apiPath: String,
        params: [String: Any]? = nil,
        headers: [String: String]? = nil,
        authorization: SKPAuthorization,
        showHUD: Bool = true,
        autoCatchError: Bool = true) -> Observable<JSON> {
        return Observable.create({ [weak self] observer -> Disposable in
            self?.request(method: method, apiPath: apiPath, params: params, headers: headers, authorization: authorization, showHUD: showHUD, autoCatchError: autoCatchError) { (json, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(json)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
    
    open func rx_upload(
        apiPath: String,
        params: [String: Any]? = nil,
        headers: [String: String]? = nil,
        multipartDatas: [SKPMultipartData],
        authorization: SKPAuthorization) -> Observable<JSON> {
        return Observable.create({ [weak self] observer -> Disposable in
            self?.upload(apiPath: apiPath,
                         params: params,
                         headers: headers,
                         multipartDatas: multipartDatas,
                         authorization: authorization,
                         progress: { (a, v) in
                            
                         }, completion: { (json, error) in
                            if let error = error {
                                observer.onError(error)
                            } else {
                                observer.onNext(json)
                            }
                            observer.onCompleted()
                         })
            return Disposables.create()
        })
    }
}

//MARK: Privates Methods
public extension SKPApiClient {
    
    fileprivate func buildApiFullPath(_ path: String) -> String {
        guard !path.lowercased().hasPrefix("http://"), !path.lowercased().hasPrefix("https://") else {
            return path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? path
        }
        
        if let fullUrl = URL(string: self.baseURL)?.appendingPathComponent(path) {
            let fullPath = fullUrl.absoluteString
            return fullPath.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? fullPath
        } else {
            let fullPath = self.baseURL.deleteSuffixPath + "/" + path.deletePrefixPath
            return fullPath.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? fullPath
        }
    }
    
    @discardableResult
    fileprivate func request(method: HTTPMethod = .get,
                             apiPath: String,
                             params: [String: Any]? = nil,
                             headers: [String: String]? = nil,
                             authorization: SKPAuthorization) -> DataRequest {
        
        let requestHeaders = authorization.headerValue + defaultHeaders + (headers ?? [:])
        let httpHeaders = HTTPHeaders(requestHeaders)
        
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        let dataRequest = session.request(apiPath, method: method, parameters: params, encoding: encoding, headers: httpHeaders)
            .validate(statusCode: 200..<300)
        
        return dataRequest
    }
    
    fileprivate func upload(
        apiPath path: String,
        params parameters: [String: Any]? = nil,
        headers headerParams: [String: String]? = nil,
        multipartDatas multiDatas: [SKPMultipartData],
        authorization: SKPAuthorization,
        progress: SKPApiUploadProgressHandler? = nil,
        completion: SKPApiCompletionHandler? = nil) {
        
        let requestHeaders = authorization.headerValue + defaultHeaders + (headerParams ?? [:])
        let headers = HTTPHeaders(requestHeaders)
        
        AF.upload(multipartFormData: { (multipartFormData) in
            var countData: UInt = 0
            multiDatas.forEach({ dataExt in
                countData += 1
                let fileName = dataExt.name.isEmptyString ? "file\(countData)" : dataExt.name
                let fileNameExt = (fileName as NSString).appendingPathExtension(dataExt.fileExtension) ?? fileName
                multipartFormData.append(dataExt.data, withName: dataExt.name, fileName: fileNameExt, mimeType: dataExt.mimeType)
            })
            // import parameters
            parameters?.forEach({ (key: String, value: Any) in
                if let dataParam = JSON(value).dataValue {
                    multipartFormData.append(dataParam, withName: key)
                }
            })
        }, to: self.buildApiFullPath(path), method: .post, headers: headers)
        .validate(statusCode: 200..<300)
        .responseJSON { (response) in
            switch response.result {
            case .success(let resultData):
                completion?(JSON(resultData), nil)
            case .failure(let error):
                completion?(JSON(), response.errorResponseWithError(error))
            }
        }.uploadProgress {
            progress?($0.completedUnitCount, $0.estimatedTimeRemaining)
        }
    }
}
