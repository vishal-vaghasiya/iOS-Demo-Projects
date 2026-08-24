//
//  APIManager.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 19/06/25.
//

import Foundation
import Alamofire
import CoreLocation

enum API_VERSION {
    case VERSION_V1
    case VERSION_V2
}

enum SERVER_NAME {
    case LIVE
    case SYSTEM
    case TESTING
    case LOCAL
    case UAT
}

enum StatusCode: Int {
    case VALIDATION_ERROR_MESSAGE = 1
    case PENDING_OTP_VERIFY = 2
    case PENDING_SIGNUP = 3
    case PENDING_SET_MPIN = 4
    case USER_TEMP_PASSWORD_CODE = 5
    case ALREADY_CREATED_ONE_ON_ONE_CHANNEL = 6
    case ERROR_MESSAGE = 8
    case SUCCESS = 10
    case SETUP_COMPANY_PROFILE = 11
    case SETUP_BRANCH_PROFILE = 12
    case SESSION_EXPIRED = 999
}

enum ErrorCode: Int {
    case DEFAULT_ERROR = 8
    case EMAIL_ERROR = 4001
    case MOBILE_ERROR = 4002
    case MOBILE_EMAIL_ERROR = 4003
    
    // Group 1: User participation and access requests
    case GROUP_CHANNEL_ALREADY_PARTICIPANT_ERROR_CODE = 1 // User already in channel
    case GROUP_CHANNEL_NOT_PARTICIPANT_REQUEST_ACCESS_ERROR_CODE = 2 // Access request required
    case GROUP_BROADCAST_CHANNEL_CREATION_ERROR_ACCESS_PENDING = 22 // Access request pending
    
    // Group 2: Inactive channels and permissions
    case GROUP_CHANNEL_REACTIVATE_ERROR_CODE = 3 // Can reactivate inactive channel
    case GROUP_BROADCAST_CHANNEL_CREATION_ERROR_INACTIVE_NO_PERMISSION = 33 // Cannot reactivate inactive channel
    case GROUP_BROADCAST_CHANNEL_CREATION_ERROR_NO_BRANCH_ACCESS = 4 // No branch access permission
    
}

struct APIResponseError: Error {
    var id: ErrorCode = .DEFAULT_ERROR
    var message: String
    var data = NSDictionary()
}

let SERVER:SERVER_NAME = .TESTING

let BASE_DOMAIN =
SERVER == .LIVE ? "carecoordinations.com" :
SERVER == .SYSTEM ? "system.carecoordinations.com" :
SERVER == .TESTING ? "test.carecoordinations.com" :
SERVER == .LOCAL ? "192.168.29.163:4000" :
SERVER == .UAT ? "uat.carecoordinations.com" :
""
let protocols = SERVER == .LOCAL ? "http" : "https"

let SOCKET_URL =  "\(protocols)://\(SERVER == .LOCAL ? "" : BASE_DOMAIN)\(SERVER == .LOCAL ? "" : ":")\(SERVER == .LIVE ? "2323" : SERVER == .SYSTEM ? "2323" : SERVER == .TESTING ? "5454" : SERVER == .UAT ? "5454" : "192.168.29.163:5555")"

/* #1 */ let BASE_URL = "\(protocols)://\(BASE_DOMAIN)/Api/v1/"
/* #1 */ let BASE_URL_V2 = "\(protocols)://\(BASE_DOMAIN)/Api/v2/"

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
    func fetchData(forAPI apiName: String,
                   withParameter param: String,
                   isAuthenticated: Bool,
                   completion: @escaping (Result<NSDictionary, APIResponseError>) -> Void) {
        
        if isAuthenticated, DefaultManager.TOKEN.isEmpty {
            completion(.failure(APIResponseError(message: "Invalid or missing token")))
            return
        }
        
        let url = BASE_URL_V2 + apiName + (param.isEmpty ? "" : "/\(param)")
        
        var headers: HTTPHeaders = [:]
        if isAuthenticated {
            headers["Authorization"] = "Bearer \(DefaultManager.TOKEN)"
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        AF.request(url, method: .get, headers: headers)
            .responseData { response in
                let endTime = CFAbsoluteTimeGetCurrent()
                let elapsedTime = endTime - startTime
                print("| API REQUEST GET \n| URL: \(url) \n| Token: \(DefaultManager.TOKEN) \n| Params: \(param) \n| ⏱️ Response Time: \(String(format: "%.2f", elapsedTime)) seconds\n")
                
                switch response.result {
                case .success(let data):
                    do {
                        if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            let flag = JSON["flag"] as? Bool ?? false
                            let code = JSON["code"] as? Int ?? 0
                            let message = JSON["message"] as? String ?? ""
                            let errorMessage = APIResponseError(message: message)
                            
                            if flag && code == StatusCode.SUCCESS.rawValue {
                                completion(.success(JSON))
                            } else {
                                completion(.failure(errorMessage))
                            }
                        } else {
                            completion(.failure(APIResponseError(message: "Invalid response format")))
                        }
                    } catch {
                        completion(.failure(APIResponseError(message: "Decoding error")))
                    }
                    
                case .failure(let error):
                    if error.localizedDescription.contains("cancel") || error.localizedDescription.lowercased().contains("urlsessiontask") {
                        return
                    }
                    completion(.failure(APIResponseError(message: error.localizedDescription)))
                }
            }
    }
    
    /// Performs a POST request without any UIKit dependencies, returning a Result via completion.
    func postData(forAPI apiName: String,
                  withParameters params: [String: Any],
                  isAuthenticated: Bool,
                  apiVersion: API_VERSION = .VERSION_V1,
                  isShowWarning: Bool = true,
                  completion: @escaping (Result<NSDictionary, APIResponseError>) -> Void) {
        if isAuthenticated, DefaultManager.TOKEN.isEmpty {
            completion(.failure(APIResponseError(message: "Invalid or missing token")))
            return
        }
        
        let url = (apiVersion == .VERSION_V1 ? BASE_URL : BASE_URL_V2) + apiName
        
        var headers: HTTPHeaders = [:]
        if isAuthenticated {
            headers["Authorization"] = "Bearer \(DefaultManager.TOKEN)"
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                let endTime = CFAbsoluteTimeGetCurrent()
                let elapsedTime = endTime - startTime
                print("| API REQUEST POST \n| URL: \(url) \n| Token: \(DefaultManager.TOKEN) \n| Params: \(params) \n| ⏱️ Response Time: \(String(format: "%.2f", elapsedTime)) seconds\n")
                
                switch response.result {
                case .success(let data):
                    do {
                        if let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            let flag = JSON["flag"] as? Bool ?? false
                            let code = JSON["code"] as? Int ?? 0
                            let message = JSON["message"] as? String ?? ""
                            let errorMessage = APIResponseError(message: message)
                            
                            if flag {
                                if code == StatusCode.SUCCESS.rawValue {
                                    completion(.success(JSON))
                                } else {
                                    completion(.failure(errorMessage))
                                }
                            } else {
                                completion(.failure(errorMessage))
                            }
                        } else {
                            completion(.failure(APIResponseError(message: "Invalid response format")))
                        }
                    } catch {
                        completion(.failure(APIResponseError(message: "Decoding error")))
                    }
                    
                case .failure(let error):
                    if error.localizedDescription.contains("cancel") || error.localizedDescription.lowercased().contains("urlsessiontask") {
                        return
                    }
                    completion(.failure(APIResponseError(message: error.localizedDescription)))
                }
            }
    }
    
}
