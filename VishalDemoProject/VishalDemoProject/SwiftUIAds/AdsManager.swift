import SwiftUI
import GoogleMobileAds
import UIKit
import AppTrackingTransparency
import AdSupport
import UserMessagingPlatform

// MARK: - Ads Info Storage
enum AdsInfo {
    static var isShowAds: Bool {
        get { true/*UserDefaults.standard.bool(forKey: #function)*/ }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var noOfAds: Int {
        get { 3/*UserDefaults.standard.integer(forKey: #function)*/ }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var noOfAdsBackscreen: Int {
        get { 5/*UserDefaults.standard.integer(forKey: #function)*/ }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var showAdsCount: Int {
        get { UserDefaults.standard.integer(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var showBackAdsCount: Int {
        get { UserDefaults.standard.integer(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var openApp_Ads: String {
        get { UserDefaults.standard.string(forKey: #function) ?? "ca-app-pub-3940256099942544/5575463023" }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var banner_Ads: String {
        get { UserDefaults.standard.string(forKey: #function) ?? "ca-app-pub-3940256099942544/2934735716" }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var interstitial_Ads: String {
        get { UserDefaults.standard.string(forKey: #function) ?? "ca-app-pub-3940256099942544/4411468910" }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var native_Ads: String {
        get { UserDefaults.standard.string(forKey: #function) ?? "ca-app-pub-3940256099942544/3986624511" }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
}

// MARK: - AdsManager
final class AdsManager: NSObject, FullScreenContentDelegate, ObservableObject, NativeAdLoaderDelegate {
    static let shared = AdsManager()
    
    private var interstitial: InterstitialAd?
    private var appOpenAd: AppOpenAd?
    private var loadTime: Date?
    private let timeoutInterval: TimeInterval = 4 * 3600
    var isLoadingAd = false
    var isShowingAd = false
    var nativeAdView: NativeAdView!
    
    private override init() {
        super.init()
    }
    
    private func initializeAdLoading() {
        MobileAds.shared.start(completionHandler: nil)
        self.requestAppOpenAd()
        self.requestInterstitial()
    }
    
    func requestInterstitial() {
        guard AdsInfo.isShowAds else { return }
        let request = Request()
        InterstitialAd.load(with: AdsInfo.interstitial_Ads, request: request) { [weak self] ad, error in
            if let error = error {
                print("Interstitial failed to load: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    var isShowAd = false {
        didSet {
            guard isShowAd, AdsInfo.isShowAds else { return }
            
            if AdsInfo.noOfAds >= AdsInfo.showAdsCount {
                guard let interstitial = interstitial else {
                    requestInterstitial()
                    return
                }
                
                interstitial.present(from: nil)
                self.isShowAd = false
                AdsInfo.noOfAds = 0    
            } else {
                AdsInfo.noOfAds += 1
            }
        }
    }
    
    var isBackShowAd = false {
        didSet {
            guard isBackShowAd, AdsInfo.isShowAds else { return }
            
            if AdsInfo.noOfAdsBackscreen >= AdsInfo.showBackAdsCount {
                guard let interstitial = interstitial else {
                    requestInterstitial()
                    return
                }
                
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    interstitial.present(from: rootVC)
                    self.isBackShowAd = false
                    AdsInfo.noOfAdsBackscreen = 0
                }
            } else {
                AdsInfo.noOfAdsBackscreen += 1
            }
        }
    }
    
    // MARK: - Consent Management
    func requestConsentInfoAndLoadAds() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    self.startConsentFlowAfterTrackingPermission()
                }
            }
        } else {
            self.startConsentFlowAfterTrackingPermission()
        }
    }
    
    private func startConsentFlowAfterTrackingPermission() {
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false
        
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] error in
            if let error = error {
                print("Consent info request failed: \(error.localizedDescription)")
            } else {
                if ConsentInformation.shared.formStatus == .available {
                    self?.loadAndShowConsentFormIfNeeded()
                } else if ConsentInformation.shared.canRequestAds {
                    self?.initializeAdLoading()
                }
            }
        }
    }
    
    private func loadAndShowConsentFormIfNeeded() {
        ConsentForm.load { form, loadError in
            if let loadError = loadError {
                print("Consent form failed to load: \(loadError.localizedDescription)")
                return
            }
            
            if let form = form {
                if ConsentInformation.shared.consentStatus == .required {
                    form.present(from: UIApplication.shared.windows.first!.rootViewController!) { dismissError in
                        if let dismissError = dismissError {
                            print("Consent form failed to present: \(dismissError.localizedDescription)")
                        }
                        
                        if ConsentInformation.shared.canRequestAds {
                            print("✅ Consent given — ready to load ads")
                            self.initializeAdLoading()
                        }
                    }
                } else {
                    print("Consent not required")
                    self.initializeAdLoading()
                }
            }
        }
    }
    
    // MARK: - App Open Ad Handling
    func requestAppOpenAd() {
        guard !isAppOpenAdAvailable(), !isLoadingAd else { return }
        
        isLoadingAd = true
        
        AppOpenAd.load(
            with: AdsInfo.openApp_Ads,
            request: Request()
        ) { [weak self] ad, error in
            self?.isLoadingAd = false
            
            if let error = error {
                print("App open ad failed to load: \(error.localizedDescription)")
                self?.appOpenAd = nil
                self?.loadTime = nil
                return
            }
            
            self?.appOpenAd = ad
            self?.loadTime = Date()
            self?.appOpenAd?.fullScreenContentDelegate = self
        }
    }
    
    private func isAppOpenAdAvailable() -> Bool {
        if let loadTime = loadTime {
            return appOpenAd != nil && Date().timeIntervalSince(loadTime) < timeoutInterval
        }
        return false
    }
    
    func showAppOpenAd() {
        // Avoid showing if an ad is already being presented
        if isShowingAd {
            print("App open ad is already showing.")
            return
        }
        
        guard let appOpenAd = appOpenAd,
              let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            print("App Open Ad not ready")
            requestAppOpenAd()
            return
        }
        
        appOpenAd.present(from: rootVC)
    }
    
    // MARK: - GADFullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitial = nil
        appOpenAd = nil
        isShowingAd = false
        requestAppOpenAd()
        requestInterstitial()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Failed to present ad: \(error.localizedDescription)")
        interstitial = nil
        appOpenAd = nil
        isShowingAd = false
        requestAppOpenAd()
    }
    
    // MARK: - NativeAdView for SwiftUI
    @Published var nativeAd: NativeAd?
    private var adLoader: AdLoader!
    
    func refreshAd() {
        adLoader = AdLoader(
            adUnitID: AdsInfo.native_Ads,
            rootViewController: nil,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(Request())
    }
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        // Native ad data changes are published to its subscribers.
        self.nativeAd = nativeAd
        nativeAd.delegate = self
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
}

// MARK: - BannerAdView for SwiftUI
struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        guard AdsInfo.isShowAds else {
            return BannerView(adSize: AdSizeBanner)
        }
        
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdsInfo.banner_Ads
        banner.load(Request())
        
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
}

/*
 How to Use
 BannerAdView()
 .frame(width: AdSizeBanner.size.width,
 height: AdSizeBanner.size.height)
 */

enum NativeAdsType {
    case SMALL
    case MEDIUM
}

// MARK: - GADNativeAdDelegate implementation
extension AdsManager: NativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: NativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
        print("\(#function) called")
    }
}

struct NativeAdViewContainer: UIViewRepresentable {
    typealias UIViewType = NativeAdView
    
    // Observer to update the UIView when the native ad value changes.
    @ObservedObject var adsManager: AdsManager
    
    func makeUIView(context: Context) -> NativeAdView {
        return
        Bundle.main.loadNibNamed(
            "NativeAdView",
            owner: nil,
            options: nil)?.first as! NativeAdView
    }
    
    func updateUIView(_ nativeAdView: NativeAdView, context: Context) {
        guard let nativeAd = adsManager.nativeAd else { return }
        
        // Each UI property is configurable using your native ad.
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        // For the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is required to make the ad
        // clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = nativeAd
    }
    // [END create_native_ad_view]
    
    private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
}
