//
//  NativeAdsManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import GoogleMobileAds
import UIKit
enum AdType: String {
    case SMALL = "NativeAdView_Small"
    case MEDIUM = "NativeAdView_Medium"
    case LARGE = "NativeAdView"
}
final class NativeAdsManager: NSObject {
    
    static let shared = NativeAdsManager()
    
    // For handling individual ad requests
    private var adCompletionHandlers: [AdLoader: (NativeAd?) -> Void] = [:]
    private var cachedAds: [NativeAd] = []
    private let maxCacheSize = 3
    private var activeLoaders: [AdLoader] = []
    private var onComplete: ((Bool) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func resetErrorCount() {
        AdsConfig.currentNativeCountErrorsAds = 0
    }
    
    private func incrementErrorCount() {
        AdsConfig.currentNativeCountErrorsAds += 1
    }
    
    private func errorCountExceeded() -> Bool {
        return AdsConfig.currentNativeCountErrorsAds >= AdsConfig.NativeCountErrorsAds
    }
    
    // MARK: - Preload Ads
    func preloadAds(count: Int = 3) {
        if DefaultManager.IS_SUBSCRIPTION {
            print("[Native] is SUBSCRIPTION")
            return
        }
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                self.loadAd()
            }
        }
    }
    
    // MARK: - Get Ad (Cached or Load On Demand)
    func getAd(in containerView: UIView,
               adType: AdType,
               completion: @escaping (Bool) -> Void) {
        self.onComplete = completion
        if DefaultManager.IS_SUBSCRIPTION {
            print("[Native] is SUBSCRIPTION")
            self.onComplete?(false)
            return
        }
        if let ad = cachedAds.first {
            cachedAds.removeFirst()
            self.displayNativeAd(in: containerView, ad, adType: adType)
            loadAd()
        } else {
            // No cached ad → Load now
            loadAd { ad in
                if ad != nil {
                    self.displayNativeAd(in: containerView, ad!, adType: adType)
                } else {
                    self.onComplete?(false)
                }
            }
        }
    }
    
    private func displayNativeAd(in containerView: UIView, _ nativeAd: NativeAd, adType: AdType) {
        // Load the custom XIB
        guard let adView = Bundle.main.loadNibNamed(adType.rawValue, owner: nil, options: nil)?.first as? NativeAdView else {
            self.onComplete?(false)
            return
        }
        
        // Set frame to match container
        adView.frame = containerView.bounds
        containerView.addSubview(adView)
        
        // Assign the nativeAd to GADNativeAdView
        adView.nativeAd = nativeAd
        
        // Bind assets
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (adView.bodyView as? UILabel)?.text = nativeAd.body
        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        if adType == .LARGE {
            adView.mediaView?.mediaContent = nativeAd.mediaContent
            // Optional extra assets
            (adView.advertiserView as? UILabel)?.text = nativeAd.advertiser
            (adView.priceView as? UILabel)?.text = nativeAd.price
            (adView.storeView as? UILabel)?.text = nativeAd.store
            // Set the star rating
            if let starRating = nativeAd.starRating {
                (adView.starRatingView as? UIImageView)?.image = getStarRatingImage(for: starRating)
                adView.starRatingView?.isHidden = false
            } else {
                adView.starRatingView?.isHidden = true // Hide if no rating
            }
        }
        adView.callToActionView?.isUserInteractionEnabled = false // Required
    }
    
    // MARK: - Internal Ad Loader
    private func loadAd(completion: ((NativeAd?) -> Void)? = nil) {
        if AdsConfig.nativeAdsPreference != .yes {
            self.onComplete?(false)
            return
        }
        guard !errorCountExceeded() else {
            print("[NativeAd] ⚠️ Max error attempts reached — not loading.")
            self.firebaseNativeAdsLog(message: "Max error attempts reached — not loading.")
            self.onComplete?(false)
            return
        }
        
        let adLoader = AdLoader(adUnitID: AdsConfig.NativeAdId,
                                rootViewController: nil,
                                adTypes: [.native],
                                options: nil)
        if let completion = completion {
            adCompletionHandlers[adLoader] = completion
        }
        adLoader.delegate = self
        activeLoaders.append(adLoader)
        adLoader.load(Request())
    }
    
    func firebaseNativeAdsLog(message: String) {
        let param: [String: Any] = [
            "ios_version": UIDevice.current.systemVersion,
            "device_model": UIDevice.current.modelName,
            "message": message
        ]
        FirebaseManager.shared.logAnalyticsEvent(name: .nativeAds, parameters: param)
    }
}

func getStarRatingImage(for rating: NSDecimalNumber) -> UIImage? {
    let ratingValue = rating.floatValue
    let fullStars = Int(ratingValue)
    let halfStar = ratingValue - Float(fullStars) >= 0.5 ? 1 : 0
    
    var starImages: [UIImage] = []
    
    // Add full stars
    for _ in 0..<fullStars {
        starImages.append(UIImage(systemName: "star.fill")!) // Replace with your full star image
    }
    // Add half star if applicable
    if halfStar > 0 {
        starImages.append(UIImage(systemName: "star.lefthalf.fill")!) // Replace with your half star image
    }
    // Add empty stars to fill to 5
    let emptyStars = 5 - fullStars - halfStar
    for _ in 0..<emptyStars {
        starImages.append(UIImage(systemName: "star")!) // Replace with your empty star image
    }
    
    // Combine star images into a single image view
    return combineStarImages(starImages)
}

func combineStarImages(_ images: [UIImage]) -> UIImage? {
    // Create a UIGraphics context to combine images
    let combinedWidth = images.count * 20 // Assuming each star is 20 points wide
    UIGraphicsBeginImageContext(CGSize(width: combinedWidth, height: 20))
    
    for (index, image) in images.enumerated() {
        image.draw(in: CGRect(x: index * 20, y: 0, width: 20, height: 20))
    }
    
    let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return combinedImage
}

// MARK: - GADNativeAdLoaderDelegate
extension NativeAdsManager: NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        activeLoaders.removeAll { $0 === adLoader }
        print("[NativeAd] loaded.")
        self.resetErrorCount()
        if let completion = adCompletionHandlers[adLoader] {
            // On-demand load → Call completion
            completion(nativeAd)
            self.onComplete?(true)
            adCompletionHandlers.removeValue(forKey: adLoader)
        } else {
            // Preloaded → Cache it
            if cachedAds.count < maxCacheSize {
                cachedAds.append(nativeAd)
                self.onComplete?(true)
                print("Cached Ads Count: \(NativeAdsManager.shared.cachedAds.count)")
            }
        }
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        activeLoaders.removeAll { $0 === adLoader }
        print("[NativeAd] Failed to load: \(error.localizedDescription)")
        self.firebaseNativeAdsLog(message: "Failed to load: \(error.localizedDescription)")
        self.incrementErrorCount()
        self.onComplete?(false)
        if let completion = adCompletionHandlers[adLoader] {
            completion(nil)
            adCompletionHandlers.removeValue(forKey: adLoader)
        }
    }
}
