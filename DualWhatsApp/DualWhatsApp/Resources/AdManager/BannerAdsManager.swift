//
//  BannerAdsManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import GoogleMobileAds
import UIKit
final class BannerAdsManager: NSObject {
    
    static let shared = BannerAdsManager()
    
    private var bannerView: BannerView?
    private var onComplete: ((Bool, CGFloat) -> Void)?
    private var bannerHeight: CGFloat = 0.0
    
    func resetErrorCount() {
        AdsConfig.currentBannerCountErrorsAds = 0
    }
    
    private func incrementErrorCount() {
        AdsConfig.currentBannerCountErrorsAds += 1
    }
    
    private func errorCountExceeded() -> Bool {
        return AdsConfig.currentBannerCountErrorsAds >= AdsConfig.BannerCountErrorsAds
    }
    
    func loadBannerAd(in containerView: UIView,
                      vc: UIViewController,
                      isLoadAdaptive: Bool,
                      completion: @escaping (Bool, CGFloat) -> Void) {
        
        if DefaultManager.IS_SUBSCRIPTION {
            print("[BannerAd] is SUBSCRIPTION")
            completion(false, bannerHeight)
            return
        }
        
        if AdsConfig.bannerAdsPreference != .yes {
            completion(false, bannerHeight)
            return
        }
        
        // ❌ If ad not loaded, try loading
        guard !BannerAdsManager.shared.errorCountExceeded() else {
            print("[BannerAd] ⚠️ Max retries exceeded — not loading or showing.")
            self.firebaseBannerAdsLog(message: "Max retries exceeded — not loading or showing.")
            completion(false, bannerHeight)
            return
        }
        
        var adSize: AdSize = AdSize()
        if isLoadAdaptive {
            // Calculate adaptive banner size based on current width
            let frame = containerView.frame.inset(by: containerView.safeAreaInsets)
            let viewWidth = frame.size.width
            adSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
        } else {
            adSize = AdSize(size: CGSize(width: 320, height: 50), flags: 0) // ✅ Correct usage
        }
        
        
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = AdsConfig.BannerAdId
        banner.rootViewController = vc
        banner.delegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(banner)
        containerView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            banner.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            banner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        banner.load(Request())
        bannerView = banner
        
        bannerHeight = adSize.size.height
        self.onComplete = completion
    }
    
    func firebaseBannerAdsLog(message: String) {
        let param: [String: Any] = [
            "ios_version": UIDevice.current.systemVersion,
            "device_model": UIDevice.current.modelName,
            "message": message
        ]
        FirebaseManager.shared.logAnalyticsEvent(name: .bannerAds, parameters: param)
    }
    
}

extension BannerAdsManager: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("[BannerAd] loaded.")
        self.resetErrorCount()
        onComplete?(true, bannerHeight)
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("[BannerAd] Failed to load: \(error.localizedDescription)")
        self.firebaseBannerAdsLog(message: "Failed to load: \(error.localizedDescription)")
        self.incrementErrorCount()
        onComplete?(false, bannerHeight)
    }
}
