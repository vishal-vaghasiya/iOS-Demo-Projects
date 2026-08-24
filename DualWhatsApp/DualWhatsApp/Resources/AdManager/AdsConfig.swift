//
//  AdsConfig.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation

enum AdDisplayPreference: String {
    case yes  // show ads
    case no   // do not show ads
    case none // do not load ads at all
}

extension AdDisplayPreference {
    init?(caseInsensitive rawValue: String) {
        self.init(rawValue: rawValue.lowercased())
    }
}

struct AdsConfig {
    
    static var startAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var appOpenAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var bannerAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var interstitialAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var nativeAdsPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    static var nativeAdsPreLoadPreference: AdDisplayPreference {
        get {
            let rawValue = UserDefaults.standard.string(forKey: #function)
                ?? AdDisplayPreference.none.rawValue
            return AdDisplayPreference(rawValue: rawValue) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
    }
    
    // OPEN ADS
    static var AppOpenAdId: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    // BANNER ADS
    static var BannerAdId: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var BannerCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var currentBannerCountErrorsAds: Int = 0
    
    // INTRSTITIAL ADS
    static var InterstitialAdId: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var InterstitialCountAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var InterstitialCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var currentInterstitialCountErrorsAds: Int = 0
    
    static var InterstitialCountShowAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    // NATIVE ADS
    static var NativeAdId: String {
        get {
            return UserDefaults.standard.string(forKey: #function) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var NativeCountErrorsAds: Int {
        get {
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    static var currentNativeCountErrorsAds: Int = 0
}
