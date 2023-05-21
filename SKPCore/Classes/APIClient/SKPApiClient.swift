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

    let queue = DispatchQueue(label: "AlamofireLoggerQueue")

    // MARK: - Pretty JSON Formatter
    private func prettyPrintJSON(_ raw: Any) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: raw, options: [.prettyPrinted]),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "\(raw)"
    }

    private func prettyPrintJSONString(_ string: String) -> String {
        guard let data = string.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return string
        }
        return prettyPrintJSON(json)
    }

    // MARK: - Log when request is created
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        debugPrint("🚀====== REQUEST START ======")
        // URL + Method
        if let url = urlRequest.url?.absoluteString, let method = urlRequest.method?.rawValue {
            debugPrint("➡️ URL: \(url) - METHOD: \(method)")
        }
        // Header
        if let header = urlRequest.allHTTPHeaderFields {
            debugPrint("📌 HEADER:")
            debugPrint(prettyPrintJSON(header))
        }
        // Body
        if let body = urlRequest.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            debugPrint("📝 BODY:")
            debugPrint(prettyPrintJSONString(bodyString))
        }
        debugPrint("🚀====== REQUEST END ======")
    }

    // MARK: - Log when request is resumed
    func requestDidResume(_ request: Request) {
        debugPrint("🔄 Resuming: \(request.request?.url?.absoluteString ?? "")")
    }

    // MARK: - Log parsed response
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        debugPrint("📥 ====== RESPONSE ======")
        // Status code
        if let status = response.response?.statusCode {
            debugPrint("📡 STATUS: \(status)")
        }
        // Pretty JSON response
        switch response.result {
        case .success(let value):
            if let json = value as? [String: Any] {
                debugPrint("✅ SUCCESS:")
                debugPrint(prettyPrintJSON(json))
            }
            else if let arr = value as? [Any] {
                debugPrint("✅ SUCCESS:")
                debugPrint(prettyPrintJSON(arr))
            }
            else {
                debugPrint("ℹ️ SUCCESS: \(value)")
            }

        case .failure(let error):
            debugPrint("❌ ERROR: \(error.localizedDescription)")
        }
        debugPrint("📥 ====== END RESPONSE ======")
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
                completion?(JSON(), nil)
                SKPPopupManager.shared.showErrorAlert(withMessage: resError.message)
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
        // Nếu là full URL thì trả luôn, KHÔNG động vào
          if path.lowercased().hasPrefix("http://") || path.lowercased().hasPrefix("https://") {
              return path
          }

          // Base URL
          guard var url = URL(string: self.baseURL) else {
              return self.baseURL
          }

          // Tách path thành từng segment theo "/"
          let segments = path
              .split(separator: "/")
              .map { String($0) }

          for segment in segments {
              // 🔹 Nếu segment đã encode (có %20, %E1...), decode về dạng thô
              let decoded = segment.removingPercentEncoding ?? segment

              // 🔹 Truyền string THÔ vào appendPathComponent
              url.appendPathComponent(decoded)
          }

          // ❗ absoluteString đã được encode đúng → KHÔNG encode thêm nữa
          return url.absoluteString
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
