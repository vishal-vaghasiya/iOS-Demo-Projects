//
//  ViewController.swift
//  ToneAnalyzer
//
//  Created by admin on 11/01/18.
//  Copyright © 2018 Vishal. All rights reserved.
//

import UIKit
import Alamofire
class ViewController: UIViewController {
    
    @IBOutlet var toneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Click Events
    @IBAction func findToneButtonClick(_ sender: UIButton) {
        if toneTextField.text != "" {
            self.GetToneFunction()
        }
        else{
            Utility.showAlert("", message: "Please Fill Fields.", viewController: self)
        }
    }
    
    func GetToneFunction(){
        let text:String = toneTextField.text!
//        let text1:String = (text as NSString).addingPercentEscapes(using: String.Encoding.utf8.rawValue)!
//        NSString *text1 = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        let text1 = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let baseURL = "https://watson-api-explorer.mybluemix.net/tone-analyzer/api/v3/tone?text=\(text1 ?? "")&version=2018-01-12&sentences=true&tones=emotion"
        
        let headers = [ "Content-Type": "application/json" ]
        var request =  URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        Alamofire.request(request).responseData { (response) in
            self.parseData(JSONData: response.data!)
        }
    }
    
    func parseData(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as! NSDictionary
            let documentTone:NSDictionary = readableJSON.value(forKey: "document_tone") as! NSDictionary
            print(documentTone)
            print((documentTone.value(forKey: "tones") as! NSArray).count)
            if (documentTone.value(forKey: "tones") as! NSArray).count > 0{
                let popMessage = "I am sorry you are upset about this problem. Please take a moment and compose yourself before continuing your conversation"
                let tones:NSArray = documentTone.value(forKey: "tones") as! NSArray
                for temp in tones {
                    let dic:NSDictionary = temp as! NSDictionary
                    let score:Double = dic.value(forKey: "score") as! Double
                    // Tone First
                    if dic.value(forKey: "tone_name") as! String == "Sadness"{
                        if (score > 0.5 && score < 0.7) {
                            Utility.showAlert("", message: popMessage, viewController: self)
                        }
                        else if (score > 0.7) {
                            Utility.showAlert("", message: popMessage, viewController: self)
                        }
                        else{
                            print("Message Send Success!")
                        }
                    }
                        // Tone Seconds
                    else if dic.value(forKey: "tone_name") as! String == "Anger"{
                        if (score > 0.5 && score < 0.7) {
                            Utility.showAlert("", message: popMessage, viewController: self)
                        }
                        else if (score > 0.7) {
                            Utility.showAlert("", message: popMessage, viewController: self)
                        }
                        else{
                            print("Message Send Success!")
                        }
                    }
                    else{
                        print("Message Send Success!")
                    }
                }
            }
            else{
                print("Message Send Success!")
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
