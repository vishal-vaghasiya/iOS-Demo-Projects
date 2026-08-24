//
//  LiveActivityManager.swift
//  VISHAL VAGHASIYA
//
//  Created by Nexios02 on 29/05/24.
//  Copyright © 2024 VISHAL VAGHASIYA. All rights reserved.
//

import Foundation
import CryptoKit
import SwiftJWT

class LiveActivityManager {
    public static let shared = LiveActivityManager()
    
    var authToken = String()
    // Function to send live activity push notification
    // LOCKED
    func pushToStartLiveActicity(deviceToken: String, success: @escaping (_ status: String) -> Void) {
        // Prepare the payload
        let payload: [String: Any] = [
            "aps": [
                "timestamp": Int(Date().timeIntervalSince1970),
                "event": "start",
                "type": 21,
                "content-state": [
                    "user_name" : "Dipak",
                    "user_name_short" : "DHA",
                    "user_logo": "",
                    "company_logo":"",
                    "professional":"CEO",
                    "distance": 5000,
                    "pendingTime":"5 mins",
                    "user_car": "Audi"
                ],
                "attributes-type": "PendingDoctorAttributes",
                "attributes": [
                    "user_name" : "Dipak",
                    "user_name_short" : "DHA",
                    "user_logo": "",
                    "company_logo":"",
                    "professional":"CEO",
                    "distance": 5000,
                    "pendingTime":"5 mins",
                    "user_car": "Audi"
                ],
                "alert": [
                    "title": "Tap to start Live Activity",
                    "body": "A live session is starting now!"
                ],
                "sound": "iphone.caf"
            ]
        ]
        
        print("payload:: \(payload)")
        // Convert payload to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            //print("Error converting payload to JSON data")
            return
        }
        
        generateAuthToken { JWTToken in
            print("authToken:41: \(JWTToken)")
            // Your code to send the JSON payload to APNs
            self.authToken = JWTToken
            let url = URL(string: "https://api.sandbox.push.apple.com:443/3/device/\(deviceToken)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("bearer " + self.authToken, forHTTPHeaderField: "Authorization") // Include your authentication token
            request.setValue("chat.homehealth4u.app", forHTTPHeaderField: "apns-topic")
            request.addValue("10", forHTTPHeaderField: "apns-priority")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending push notification: \(error.localizedDescription)")
                    success("\(error.localizedDescription)")
                } else if let response = response as? HTTPURLResponse {
                    if response.statusCode == 403 {
                        self.generateAuthToken { JWTToken in
                            self.authToken = JWTToken
                            self.pushToStartLiveActicity(deviceToken: deviceToken) { status in
                                success(status)
                            }
                        }
                    } else {
                        print("Push notification sent successfully. Status code: \(response.statusCode)")
                        success("\(response.statusCode)")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func updateLiveActicity(pushToken: String, distance: Int, success: @escaping (_ status: String) -> Void) {
        // Prepare the payload
        let payload: [String: Any] = [
            "aps": [
                "timestamp": Int(Date().timeIntervalSince1970),
                "event": "update",
                "stale-date": Int(Date().addMinutes(n: 1).timeIntervalSince1970),
                "content-state": [
                    "user_name" : "\(Int(Date().timeIntervalSince1970))",
                    "user_name_short" : "VK",
                    "user_logo": "",
                    "company_logo":"",
                    "professional":"CEO",
                    "distance": distance,
                    "pendingTime":"1 mins",
                    "user_car": "Audi"
                ],
                "alert": [
                    "title": "Update Live Activity",
                    "body": "A live session is starting now!"
                ],
                "sound": "iphone.mp3"
            ]
        ]
        
        print("payload:: \(payload)")
        // Convert payload to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            //print("Error converting payload to JSON data")
            return
        }
        
        //        generateAuthToken { JWTToken in
        print("authToken:41: \(authToken)")
        // Your code to send the JSON payload to APNs
        let url = URL(string: "https://api.sandbox.push.apple.com:443/3/device/\(pushToken)")!
        print("UPDATE URL: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("bearer " + self.authToken, forHTTPHeaderField: "Authorization") // Include your authentication token
        
        request.addValue("chat.homehealth4u.app.push-type.liveactivity", forHTTPHeaderField: "apns-topic")
        request.addValue("liveactivity", forHTTPHeaderField: "apns-push-type")
        request.addValue("10", forHTTPHeaderField: "apns-priority")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending push notification: \(error.localizedDescription)")
                success("\(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse {
                if response.statusCode == 403 {
                    self.generateAuthToken { JWTToken in
                        self.authToken = JWTToken
                        self.updateLiveActicity(pushToken: pushToken, distance: distance) { status in
                            success(status)
                        }
                    }
                } else {
                    print("Push notification sent successfully. Status code: \(response.statusCode)")
                    success("\(response.statusCode)")
                }
            }
        }
        task.resume()
        //        }
    }
    
    //LOCKED
    func endLiveActicity(pushToken: String, success: @escaping (_ status: String) -> Void) {
        // Prepare the payload
        let payload: [String: Any] = [
            "aps": [
                "timestamp": Int(Date().timeIntervalSince1970),
                "event": "end",
                "content-state": [
                    "user_name" : "Vishal",
                    "user_name_short" : "VK",
                    "user_logo": "",
                    "company_logo":"",
                    "professional":"CEO",
                    "distance": 1,
                    "pendingTime":"1 mins",
                    "user_car": "Audi"
                ],
                "dismissal-date": Int(Date().timeIntervalSince1970),
                "alert": [
                    "title": "End Live Activity",
                    "body": "A live session is starting now!"
                ],
                "sound": "iphone.caf"
            ]
        ]
        
        print("payload:: \(payload)")
        // Convert payload to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            //print("Error converting payload to JSON data")
            return
        }
        
        //        generateAuthToken { JWTToken in
        print("authToken:41: \(authToken)")
        // Your code to send the JSON payload to APNs
        let url = URL(string: "https://api.sandbox.push.apple.com:443/3/device/\(pushToken)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("bearer " + authToken, forHTTPHeaderField: "Authorization") // Include your authentication token
        
        request.addValue("chat.homehealth4u.app.push-type.liveactivity", forHTTPHeaderField: "apns-topic")
        request.addValue("liveactivity", forHTTPHeaderField: "apns-push-type")
        request.addValue("10", forHTTPHeaderField: "apns-priority")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending push notification: \(error.localizedDescription)")
                success("\(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse {
                print("Push notification sent successfully. Status code: \(response.statusCode)")
                if response.statusCode == 403 {
                    self.generateAuthToken { JWTToken in
                        self.authToken = JWTToken
                        self.endLiveActicity(pushToken: pushToken) { status in
                            success(status)
                        }
                    }
                } else {
                    success("\(response.statusCode)")
                }
            }
        }
        task.resume()
        //        }
    }
    
    func generateAuthToken(success: @escaping (_ JWTToken: String) -> Void) {
//        let privateKeyPath = Bundle.main.path(forResource: "AuthKey_2QPPUF5ASX", ofType: "p8")!
//        let privateKey = try? String(contentsOfFile: privateKeyPath, encoding: .utf8)
        let privateKey = "-----BEGIN PRIVATE KEY-----\nMIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgOjg79AsuKmuQebnSDDJrLsi9wYOgR+uPeWg+ihZzToigCgYIKoZIzj0DAQehRANCAARkL6ZKcPWZhYWUOZ727S/z2iElyDoN02eAoPMoDJTkZG8T33HEDDT5LqDBmb3x3Y8MTybuQYUkevVuurGPaiCj\n-----END PRIVATE KEY-----\n"
        let claims = Payload(iss: "CA6XCFWPY9", iat: Date())
        let header = Header(kid: "2QPPUF5ASX")
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.es256(privateKey: Data(privateKey.utf8))
        do {
            let signedJWT = try jwt.sign(using: signer)
            success(signedJWT)
        } catch {
            print("Error: \(error.localizedDescription) \n\(error.localizedDescription) \n\(error)")
        }
    }
    
    func encodeBase64(_ string: String) -> String {
        return Data(string.utf8).base64EncodedString()
    }
}

struct Payload: Claims {
    let iss: String
    let iat: Date
}

extension Date {
    func addHours(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .hour, value: n, to: self)!
    }
    
    func addMinutes(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .minute, value: n, to: self)!
    }
}
//f049bca72d509912f56f2ebee69c7b08adfeca2d35db139b0aa8dd8f6cca193cac84952398f95a005846cc7b17830faa7716ae7a7b1a111ffccc9dac02d3bc
