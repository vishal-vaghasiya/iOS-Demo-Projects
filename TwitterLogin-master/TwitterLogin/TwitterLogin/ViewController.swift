//
//  ViewController.swift
//  TwitterLogin
//
//  Created by Admin on 05/01/19.
//  Copyright © 2019 VISHAL. All rights reserved.
//

import UIKit
import TwitterKit
class ViewController: UIViewController, TWTRComposerViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userName))");
                print("userID \(String(describing: session?.userID))");
                print("authToken \(String(describing: session?.authToken))");
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }

    // USing custom button
    @IBAction func LoginButtonClick(_ sender: UIButton) {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userName))");
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
    }
    
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        print("composerDidCancel")
    }
    
    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        print("composerDidSucceed")
    }
    
    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        print("composerDidFail")
    }
}

