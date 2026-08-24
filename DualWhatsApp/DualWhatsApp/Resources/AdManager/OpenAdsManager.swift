//
//  OpenAdsManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import GoogleMobileAds
import UIKit

final class OpenAdsManager: NSObject {

    static let shared = OpenAdsManager()

    private var appOpenAd: AppOpenAd?
    private var isFirstAttemptFailed = false
    private var onComplete: (() -> Void)?

    private let timeoutInterval: TimeInterval = 4 * 3_600
    private var loadTime: Date?
    private var isLoadingAd = false
    private var isShowingAd = false
    
    private func wasLoadTimeLessThanNHoursAgo(timeoutInterval: TimeInterval) -> Bool {
        // Check if ad was loaded more than n hours ago.
        if let loadTime = loadTime {
            return Date().timeIntervalSince(loadTime) < timeoutInterval
        }
        return false
    }
    
    private func isAdAvailable() -> Bool {
        // Check if ad exists and can be shown.
        return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(timeoutInterval: timeoutInterval)
    }
    
    func loadAndShow(completion: @escaping () -> Void) {
        self.onComplete = completion

        if DefaultManager.IS_SUBSCRIPTION {
            print("[AppOpenAd] is SUBSCRIPTION")
            completion()
            return
        }
        
        if isLoadingAd || isAdAvailable() {
            completion()
            return
        }
        
        isLoadingAd = true
        let request = Request()
        AppOpenAd.load(
            with: AdsConfig.AppOpenAdId,
            request: request
        ) { ad, error in
            if let error = error {
                self.isLoadingAd = false
                self.appOpenAd = nil
                self.loadTime = nil
                if !self.isFirstAttemptFailed {
                    self.isFirstAttemptFailed = true
                    self.loadAndShow(completion: completion)
                } else {
                    self.onComplete?()
                }
                print("[AppOpenAd] Failed to load: \(error)")
                self.firebaseOpenAdsLog(message: "Failed to load: \(error)")
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            self.isLoadingAd = false
            print("[AppOpenAd] loaded.")
            
            if self.isShowingAd {
                print("[AppOpenAd] is already showing.")
                self.onComplete?()
                return
            }
            
            print("[AppOpenAd] will be displayed.")
            ad?.present(from: VariableInfo.rootController)
        }
    }
    
    func loadAd() {
        if DefaultManager.IS_SUBSCRIPTION {
            print("[AppOpenAd] is SUBSCRIPTION")
            return
        }
        
        if isLoadingAd || isAdAvailable() {
            return
        }
        if AdsConfig.appOpenAdsPreference == .yes {
            isLoadingAd = true
            AppOpenAd.load(with: AdsConfig.AppOpenAdId, request: Request()) { ad, error in
                if let error = error {
                    self.isLoadingAd = false
                    self.appOpenAd = nil
                    self.loadTime = nil
                    print("[AppOpenAd] Failed to load: \(error)")
                    self.firebaseOpenAdsLog(message: "Failed to load: \(error)")
                    return
                }
                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                self.loadTime = Date()
                self.isLoadingAd = false
                print("[AppOpenAd] loaded.")
            }
        }
    }
    
    func tryToPresentAd() {
        
        if DefaultManager.IS_SUBSCRIPTION {
            print("[AppOpenAd] is SUBSCRIPTION")
            return
        }
        
        if isShowingAd {
            print("[AppOpenAd] is already showing.")
            return
        }
        
        if !isAdAvailable() {
            print("[AppOpenAd] is not ready yet.")
            loadAd()
            return
        }
        
        if let ad = appOpenAd {
            print("[AppOpenAd] will be displayed.")
            isShowingAd = true
            ad.present(from: VariableInfo.rootController!)
        }
    }
    
    func firebaseOpenAdsLog(message: String) {
        let param: [String: Any] = [
            "ios_version": UIDevice.current.systemVersion,
            "device_model": UIDevice.current.modelName,
            "message": message
        ]
        FirebaseManager.shared.logAnalyticsEvent(name: .openAds, parameters: param)
    }
}

// MARK: - FullScreenContentDelegate
extension OpenAdsManager: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[AppOpenAd] Dismissed")
        appOpenAd = nil
        isShowingAd = false
        loadAd()
        onComplete?()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[AppOpenAd] Failed to present: \(error.localizedDescription)")
        self.firebaseOpenAdsLog(message: "Failed to present: \(error.localizedDescription)")
        appOpenAd = nil
        isShowingAd = false
        loadAd()
        onComplete?()
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[AppOpenAd] Will present")
    }
}
