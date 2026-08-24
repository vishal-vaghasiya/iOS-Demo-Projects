//
//  SecureConfigManager.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 30/07/25.
//

/*
 let baseURL = SecureConfigManager.shared.value(forKey: "API_BASE_URL")
 print("🌐 Base URL → \(baseURL ?? "Not found")")

 let firebaseKey = SecureConfigManager.shared.value(forKey: "FIREBASE_API_KEY")
 */

import Foundation

final class SecureConfigManager {

    // MARK: - Singleton
    static let shared = SecureConfigManager()

    // MARK: - Private Properties
    private var config: [String: Any] = [:]

    // MARK: - Init
    private init() {
        loadConfig()
    }

    // MARK: - Load Config
    private func loadConfig() {
        if let url = Bundle.main.url(forResource: "AppSecureConfig", withExtension: "plist"),
           let data = try? Data(contentsOf: url) {
            do {
                if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                    self.config = plist
                }
            } catch {
                print("❌ Failed to load AppSecureConfig.plist: \(error)")
            }
        } else {
            print("❌ AppSecureConfig.plist not found in bundle")
        }
    }

    // MARK: - Public Method
    func value(forKey key: String) -> String? {
        return config[key] as? String
    }
}
