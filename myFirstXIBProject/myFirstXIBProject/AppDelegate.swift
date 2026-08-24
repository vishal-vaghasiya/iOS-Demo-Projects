//
//  AppDelegate.swift
//  myFirstXIBProject
//
//  Created by Nexios02 on 09/01/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController: UINavigationController?
    var mainMenuVC: MainMenuVC?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        
        self.mainMenuVC = MainMenuVC.init(nibName: "MainMenuVC", bundle: nil)
        self.navigationController = UINavigationController(rootViewController: self.mainMenuVC!)
        self.navigationController?.navigationBar.isHidden = true
        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }

}
