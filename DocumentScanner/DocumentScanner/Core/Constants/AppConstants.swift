//
//  AppConstants.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation

struct AppConstants {
    static let appName = "Document Scanner"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    static let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // Support and Info URLs
    static let supportEmail = "support@nexiostechnologies.com"
    static let privacyPolicyURL = URL(string: "https://nexiostechnologies.com/privacy-pdftoolbox")!
    static let termsOfUseURL = URL(string: "https://nexiostechnologies.com/terms-pdftoolbox")!
    
    // Core Limits
    static let maxImageSelectionCount = 50
    static let maxPDFFileSizeMB = 100
    static let maxCompressedQuality: Double = 0.8
    static let minCompressedQuality: Double = 0.1
    
    // Temporary File Folder
    static let tempDirectoryName = "DocumentScanner_Temp"
}
