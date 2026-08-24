//
//  FirebaseManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import UIKit
import FirebaseAnalytics

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    func logAnalyticsEvent(name eventName: AnalyticsEventName, parameters: [String: Any] = [:]) {
        Analytics.logEvent(eventName.rawValue, parameters: parameters)
    }
}

enum AnalyticsEventName: String {
    case select_language
    
    case bannerAds = "BannerAd"
    case openAds = "OpenAd"
    case interstitialAds = "InterstitialAd"
    case nativeAds = "NativeAd"
}
