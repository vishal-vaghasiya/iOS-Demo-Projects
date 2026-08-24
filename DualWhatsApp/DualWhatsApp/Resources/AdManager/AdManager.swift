//
//  AdManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import AppTrackingTransparency
import UIKit
import GoogleMobileAds
import FirebaseCore
import FirebaseCrashlytics
//import FBAudienceNetwork
class AdManager: NSObject {
    
    static let shared = AdManager()
    
    func requestAppTrackingPermission(completion: @escaping () -> Void) {
        ATTrackingManager.requestTrackingAuthorization { _ in
            completion()
        }
    }
    
    func configureAdManager() {
        /*FBAudienceNetworkAds.initialize(with: nil, completionHandler: nil)
        FBAdSettings.setAdvertiserTrackingEnabled(true)
        AppEvents.activateApp()
        Settings.isAutoLogAppEventsEnabled = true
        Settings.isAdvertiserIDCollectionEnabled = true*/
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    }
    
    func resetErrorCount() {
        BannerAdsManager.shared.resetErrorCount()
        InterstitialAdsManager.shared.resetErrorCount()
        NativeAdsManager.shared.resetErrorCount()
    }
 
    // MARK: - App Open Ad
    func tryToPresentAd() {
        OpenAdsManager.shared.tryToPresentAd()
    }
    
    // MARK: - Interstitial Ad
    func loadInterstitialAd() {
        InterstitialAdsManager.shared.loadAd()
    }
    
    func showInterstitialAd(from viewController: UIViewController,
                            completion: @escaping () -> Void) {
        InterstitialAdsManager.shared.showAd(from: viewController, completion: completion)
    }

    // MARK: - Banner Ad
    func loadBannerAd(in containerView: UIView,
                      rootViewController: UIViewController,
                      isLoadAdaptive: Bool = true,
                      completion: @escaping (Bool, CGFloat) -> Void) {
        containerView.clipsToBounds = true
        BannerAdsManager.shared.loadBannerAd(in: containerView, vc: rootViewController, isLoadAdaptive: isLoadAdaptive, completion: completion)
    }

    // MARK: - Native Ad
    func loadNativeAd(in containerView: UIView,
                      adType: AdType,
                      completion: @escaping (Bool) -> Void) {
        containerView.clipsToBounds = true
        NativeAdsManager.shared.getAd(in: containerView, adType: adType, completion: completion)
    }
    
}
