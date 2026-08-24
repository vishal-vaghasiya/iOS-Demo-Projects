//
//  ReachabilityManager.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import Reachability

final class ReachabilityManager {
    
    static let shared = ReachabilityManager()
    
    private let reachability = try! Reachability()
    
    private init() {
        startMonitoring()
    }
    
    // MARK: - Start Monitoring
    private func startMonitoring() {
        reachability.whenReachable = { reach in
            //print("✅ Network reachable via \(reach.connection.description)")
        }
        
        reachability.whenUnreachable = { _ in
            print("🚫 Network not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("❌ Unable to start Reachability notifier: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Check Network Availability
    func isConnectedToNetwork() -> Bool {
        return reachability.connection != .unavailable
    }
    
    // MARK: - Stop Monitoring (optional)
    func stopMonitoring() {
        reachability.stopNotifier()
    }
}
