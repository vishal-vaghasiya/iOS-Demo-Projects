import Foundation
import Combine

@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var isRunning: Bool = false

    private var timer: AnyCancellable?
    private var backgroundDate: Date?

    var displayTime: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedSeconds += 1
            }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    func stop() {
        pause()
    }

    func reset() {
        stop()
        elapsedSeconds = 0
    }

    // Call from .onReceive(NotificationCenter...) in your View
    func handleBackground() {
        backgroundDate = Date()
        pause()
    }

    func handleForeground() {
        if let bg = backgroundDate {
            let elapsed = Int(Date().timeIntervalSince(bg))
            elapsedSeconds += elapsed
            backgroundDate = nil
        }
        if isRunning == false { /* user was mid-game, restart */ }
        // Re-start only if there was an active game — GameViewModel controls this
    }
}
