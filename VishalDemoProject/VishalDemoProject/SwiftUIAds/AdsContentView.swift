//
//  AdsContentView.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 04/08/25.
//

import SwiftUI
import GoogleMobileAds

// MARK: - Example SwiftUI Usage
struct AdsContentView: View {
    @State private var showInterstitial = false
    @StateObject private var adsManager = AdsManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            BannerAdView()
                .frame(width: AdSizeBanner.size.width,
                       height: AdSizeBanner.size.height)

            Button("Show Interstitial Ad") {
                AdsManager.shared.isShowAd = true
            }

            Button("Show App Open Ad") {
                AdsManager.shared.showAppOpenAd()
            }

            NativeAdViewContainer(adsManager: adsManager)
              .frame(maxHeight: 300)
              .onAppear {
                  adsManager.refreshAd()
              }
        }
        .onAppear {
            // Request user consent and load initial ads
            AdsManager.shared.requestConsentInfoAndLoadAds()

            // Preload interstitial ad
            AdsManager.shared.requestInterstitial()

            // Preload app open ad
            AdsManager.shared.requestAppOpenAd()
            
        }
    }
}

//#Preview {
//    AdsContentView()
//}
