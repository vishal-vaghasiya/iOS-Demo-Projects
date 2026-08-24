import Foundation
import UIKit

@MainActor
final class AdsViewModel: ObservableObject {
    @Published var isLoadingAd: Bool = false
    @Published var isPresentingAd: Bool = false
    @Published var hintGranted: Bool = false

    private let adsService: AdsService

    init(adsService: AdsService = .shared) {
        self.adsService = adsService
    }

    func requestHint(presentingViewController: UIViewController, onGranted: @escaping () -> Void) {
        Task {
            isLoadingAd = true
            let rewarded = await adsService.showRewardedAd(from: presentingViewController)
            isLoadingAd = false
            if rewarded {
                hintGranted = true
                onGranted()
            }
        }
    }

    func preloadAd() {
        Task { await adsService.loadAd() }
    }
}
