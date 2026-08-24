import SwiftUI
import Foundation
import Combine
import CoreData

class TimerManager: ObservableObject {
    @Published var secondsElapsed: Int = 0
    @Published var isPaused: Bool = false
    private var timer: Timer?
    
    
    func start() {
        timer?.invalidate() // Stop existing timer if any
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.secondsElapsed += 1
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func pause() {
        timer?.invalidate()
        isPaused = true
    }
    
    func reset(context: NSManagedObjectContext) {
        saveSession(context: context)
        stop()
        secondsElapsed = 0
        isPaused = false
    }
    
    func saveSession(context: NSManagedObjectContext) {
        let session = TimerSession(context: context)
        session.id = UUID()
        session.endDate = Date()
        session.elapsed = Int64(secondsElapsed)
        do {
            try context.save()
            print("Timer session saved")
        } catch {
            print("Failed to save session: \(error.localizedDescription)")
        }
    }
}
