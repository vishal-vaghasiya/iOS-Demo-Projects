import Foundation
import UIKit

// MARK: - AdsService
// Replace the stub implementation with real Google AdMob SDK calls.
// 1. Add pod 'Google-Mobile-Ads-SDK' to your Podfile (or SPM equivalent).
// 2. Import GoogleMobileAds at the top of this file.
// 3. Replace StubRewardedAd with GADRewardedAd.

protocol RewardedAdProtocol {
    var isReady: Bool { get }
    func load() async
    func present(from viewController: UIViewController) async throws
}

enum AdsError: Error {
    case adNotReady
    case adFailed(Error)
}

// ─── Stub (remove when integrating real AdMob) ────────────────────────────────
class StubRewardedAd: RewardedAdProtocol {
    var isReady: Bool = false

    func load() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)  // simulate 1s network
        isReady = true
    }

    func present(from viewController: UIViewController) async throws {
        guard isReady else { throw AdsError.adNotReady }
        // Simulate ad watch delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        isReady = false
    }
}
// ─────────────────────────────────────────────────────────────────────────────

@MainActor
class AdsService: ObservableObject {
    static let shared = AdsService()

    @Published var isAdLoading: Bool = false
    @Published var isAdPresenting: Bool = false

    // Replace with GADRewardedAd instance after AdMob integration
    private var rewardedAd: RewardedAdProtocol = StubRewardedAd()

    // AdMob Ad Unit ID — replace "ca-app-pub-XXXXX/YYYYY" with your real unit
    static let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313" // test ID

    func loadAd() async {
        isAdLoading = true
        await rewardedAd.load()
        isAdLoading = false
    }

    /// Returns true if the user successfully watched the ad (reward granted).
    func showRewardedAd(from viewController: UIViewController) async -> Bool {
        do {
            isAdPresenting = true
            try await rewardedAd.present(from: viewController)
            isAdPresenting = false
            await loadAd()  // preload next ad
            return true
        } catch {
            isAdPresenting = false
            return false
        }
    }
}
