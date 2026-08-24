//
//  ViewController.swift
//  WidgetDemo
//
//  Created by ios-m2 on 01/06/23.
//

import UIKit
import ActivityKit
import CryptoKit
import SwiftJWT
import Alamofire
@available(iOS 16.1, *)
class ViewController: UIViewController {
    
    //var activity: Activity<PizzaDeliveryAttributes>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func startLiveActivity(){
        let iat = Date()
        let calendar = Calendar.current
        let exp = calendar.date(byAdding: .hour, value: 1, to: iat)!
        
        let privateKeyPEM = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCbIBC3DAIB7iLl\nlW8/UDrpSbS7Zy62v2FR72ptj3d83z80qT/uQaRn+V8aKJWY4Fkkg6n0kmeHBypb\nubAQObffHSP16fsllh+2It2TVRxVJOMYFKH0OU6qvTFGA/UM8VxsDaQjn3sz3vNO\nI/PDVNHtKjFZHEqLkZP4rpkkkQiT54rd3ecT50oxGqnjQvF9de8lNYDS0L9BwD3H\nGQwbzTTT+xN3y2ur3BPUObf0TK5k8ibcatECcnl82MQxfXpQmUn4mMrT2Vs/SKmo\n0gFmtZibuwUfe+aOGIDEPnpd1N6FSOaEfLMi4CUbFlcbE8iDWO7QYaT2/SDJ7XZD\nHyCkuopVAgMBAAECggEAP8BSTj/flVZ+PfcHZLA+vcA+R+Q0VQNa5hbsGMGkvAtt\niOFjtjGA9QANnwz9yfmteO2pS6tdY6dEt7Sc0FZAJC/wJvC1d7F2L96tTA7m2XES\n6UMVee6RT2b4WItoypxovLlwcvloYx1lxX/N/sEdkwfLhxEy65/0/XcX1ejK6ylR\nmcUwCeNnO7tKR9tQktLTwDBg9JwyJCqLIYXYNnHx81uk8KGrL1KRWl50SuC/D49e\nMMx0Gu4BcFKLJ/fSTWRIZO8dBmKmKViv0U2t6+3olFwNeq9Y7NNgz6Er5eg1wP0S\nvfgCr4IaGfK2rfpsNZ3h0JQiWCk6b6Q5De9H3DlwcwKBgQDTcGe30npkH8Z6BW5+\nJSXZeb28mdRYcs3JrrQv23dz/m9oSst6BKBfYCJWb+RRx6U5k98usP7Uo+xcEvbS\nA+nzJlT69r6VrcpQRnBVLr8prl2ePIZ4vD0wExx0N1tZYx8Rahx6USOZpFYZBx2Y\nRJfhGZkFXiWVjSXTN2iuMbHd6wKBgQC70WhY58CFhnUY+PwFJNl7XgLg84Sb6xRu\nP8hROuHmLQ5kL5WGMOeIXGNRl+beInvUxf/HraJFfIWWdwkoMgI1pudL5wy/MMrP\nSHdq88V6cJj+jcl6MYex0oTdeS4zpqAOjNmyn9Ge7yV7jcVItKIGh1crRMQIwDFl\nXfSQQHvovwKBgDytGiaHUTYgZD2qB15N3MG/DPLtliFXuLRy3SSKr4nq7x+XrzKx\n1y/nj5MMgxHw3/pY9AgbJNXywKZfjtMP6ngrfOGUI3ciq1dED4JyastUTWtWZSSK\nqGh+Y4D6Tc2mA0llEQ0M8dFqdoayIw0KSid/yAjhTpnPKpalZPXwLuHHAoGAHZnm\ngUSdYi4L3JC5X7IsGLZ7a6rVtqE5ShsBXlQScG2ffAjH3ytsAmDVQnHXcCEtNR6z\nrmveTGdQwqMmLVCcaopQn/TdXHC7NiossA2VjTOb2VrNa1XNFiigyiskLf3P8hse\n4Hkx14PHe46fjlLxymegRHCFGP/5iQli1y1img8CgYEAraWLXwDJVcpGswT4chBM\nxeZnPtoPzxfpTfJI7l9hoCQzpOEGEIMtrHuLQyV26QBS/V15LURzJkKSccS0OHyQ\nQIkL71dVkFGKkN/jqhKa/pWhQj7JHI6DAAX8nNfyfCPbHKvs/z76/nC57sYOKTZp\nyv3AGBtxlivQdHqi5xL9o+o=\n-----END PRIVATE KEY-----\n"
        
        guard let privateKeyData = privateKeyPEM.data(using: .utf8) else {
            fatalError("Private key data could not be created.")
        }
        
        let myHeader = Header(kid: "470fbaec234f75108a15531168e73fc37deb193e")
        struct Payload: Claims {
            let iss: String
            let scope: String
            let aud: String
            let exp: Date
            let iat: Date
            let admin: Bool
        }
        
        let payload = Payload(iss: "homehealth4u-chat@appspot.gserviceaccount.com", scope: "https://www.googleapis.com/auth/firebase.messaging", aud: "https://oauth2.googleapis.com/token", exp: exp, iat: iat, admin: true)
        var myJWT = JWT(header: myHeader, claims: payload)
        let privateKey: Data = privateKeyData//try! Data(contentsOf: privateKeyPath, options: .alwaysMapped)
        let jwtSigner = JWTSigner.rs256(privateKey: privateKey)
        let signedJWT = try! myJWT.sign(using: jwtSigner)
        
        self.makeAccessToken(jwtToken: signedJWT)
    }
    
    func makeAccessToken(jwtToken: String){
        let param: [String: String] = [
            "assertion": jwtToken,
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer"
        ]
        
        let header: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        AF.request(URL(string: "https://oauth2.googleapis.com/token")!, method: .post, parameters: param, headers: header)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    if let data = response.value as? [String: Any] {
                        if let accessToken = data["access_token"] as? String {
                            self.sendNotification(accessToken: accessToken)
                        }
                    }
                    break
                case .failure(let error):
                    if let data = response.data {
                        print("Response Error:- \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                        
                    }
                    break
                }
            }
    }
    
    func sendNotification(accessToken: String){
        let targetDeviceToken = "eW9DsAxVyU0coqXpIZNw5k:APA91bHqZg_vpP63YQOj-ydROfutRsOm08SKh4Wu90iLhKmdDaXcMqN0zRrZb9F5zOK8x9YgnNgSIATlGH9uMH9fLlOV_8XS0f0ZmymxEwpJ0X3wrsTcQTfQS4Q9FQ4hrDE5T4CaUEnb"
        
        let notification: [String: Any] = [
            "title": "replace_with_title",
            "body": "replace_with_remark"
        ]
        
        let data: [String: Any] = [
            "remark": "replace_with_title",
            "title": "replace_with_remark"
        ]
        
        let apnsPayload: [String: Any] = [
            "aps": [
                "alert": [
                    "title": "Hello",
                    "body": "Body",
                    "action-loc-key": "Details1"
                ],
                "badge": 0,
                "mutable-content": 1,
                "type": "21",
                "channel_id": "1",
                "distance": "10",
                "time": "7894561234",
                "company_logo": "",
                "user_logo": "",
                "user_name": "",
                "event": "START"
            ]
        ]
        
        let apns: [String: Any] = [
            "payload": apnsPayload
        ]
        
        let message: [String: Any] = [
            "token": targetDeviceToken,
            "notification": notification,
            "data": data,
            "apns": apns
        ]
        
        let requestData: [String: Any] = ["message": message]
        let jsonData = try? JSONSerialization.data(withJSONObject: requestData)
        
        var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/v1/projects/homehealth4u-chat/messages:send")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        AF.request(request)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    if let data = response.data {
                        print("Response Error:- \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                    }
                    break
                }
            }
    }
    
    
    @IBAction func btnStartAction(_ sender: UIButton) {
        //self.startActivity()
        self.startLiveActivity()
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        self.updateActivity()
    }
    
    @IBAction func btnEndAction(_ sender: UIButton) {
        self.endActivity()
    }
}

extension Data {
    
    init?(base64URLEncodedString: String) {
        let unpadded = base64URLEncodedString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padCount: Int
        switch unpadded.count % 4 {
        case 0: padCount = 0
        case 1: return nil
        case 2: padCount = 2
        case 3: padCount = 1
        default: fatalError()
        }
        self.init(base64Encoded: String(unpadded + String(repeating: "=", count: padCount)))
    }
    
    var base64URLEncodedString: String {
        let base64 = self.base64EncodedString()
        return String(base64.split(separator: "=").first!)
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}

@available(iOS 16.1, *)
extension ViewController {
    func startActivity() {
        let pizzaDeliveryAttributes = PendingDeliveryAttributes(numberOfPizzas: 1, totalAmount:"$99")
        
        let initialContentState = PendingDeliveryAttributes.PendingDeliveryStatus(driverName: "DH 👨‍⚕️", estimatedDeliveryTime: Date()...Date().addingTimeInterval(1 * 60))
        
        do {
            let deliveryActivity = try Activity<PendingDeliveryAttributes>.request(
                attributes: pizzaDeliveryAttributes,
                contentState: initialContentState,
                pushType: nil)
            print("Requested a pizza delivery Live Activity \(deliveryActivity.id)")
        } catch (let error) {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription)")
        }
    }
    func updateActivity() {
        Task {
            let updatedDeliveryStatus = PendingDeliveryAttributes.PendingDeliveryStatus(driverName: "DH 👨‍⚕️", estimatedDeliveryTime: Date()...Date().addingTimeInterval(60 * 60))
            
            for activity in Activity<PendingDeliveryAttributes>.activities{
                await activity.update(using: updatedDeliveryStatus)
            }
        }
    }
    func endActivity() {
        Task {
            for activity in Activity<PendingDeliveryAttributes>.activities{
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
    func showAllDeliveries() {
        Task {
            for activity in Activity<PendingDeliveryAttributes>.activities {
                print("Pizza delivery details: \(activity.id) -> \(activity.attributes)")
            }
        }
    }
}


