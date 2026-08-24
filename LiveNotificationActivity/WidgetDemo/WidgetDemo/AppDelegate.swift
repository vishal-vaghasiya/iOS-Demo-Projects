//
//  AppDelegate.swift
//  WidgetDemo
//
//  Created by ios-m2 on 01/06/23.
//

import UIKit
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().delegate = self
        
        application.registerForRemoteNotifications()
        registerForPushNotifications(application: application)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        DefaultManager.FCM_TOKEN = fcmToken!
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        print("token", fcmToken)
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    // [END ios_10_data_message]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        DefaultManager.FCM_TOKEN = fcmToken
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPushNotifications(application: UIApplication){
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        var authOptions: UNAuthorizationOptions!
        if #available(iOS 15.0, *) {
            authOptions = [.alert, .badge, .sound, .providesAppNotificationSettings, .timeSensitive, .carPlay, .criticalAlert]
        } else {
            authOptions = [.alert, .badge, .sound, .providesAppNotificationSettings, .carPlay, .criticalAlert]
        }
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { (granted, error) in
                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            })
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        _ = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        // Open settings view controller
    
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        setNotificationTap(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }

    func setNotificationTap(userInfo: [AnyHashable: Any]) {
        if userInfo.isEmpty {
            return
        }

    }
}

class DefaultManager {
    static var FCM_TOKEN: String {
        get {
            return (UserDefaults.standard.string(forKey: "fcmtoken") ?? "123")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "fcmtoken")
            UserDefaults.standard.synchronize()
        }
    }
}

