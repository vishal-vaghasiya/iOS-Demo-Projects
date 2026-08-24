//
//  WebManager.swift
//  DualWhatsApp
//
//  Created by Nexios Mac 4 on 09/10/25.
//

import Foundation
import WebKit
import UIKit

final class WebManager: NSObject, WKNavigationDelegate {

    static let shared = WebManager()

    private override init() {
        super.init()
    }
    
    func loadWhatsAppWeb(in webView: WKWebView) {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.websiteDataStore = .default()
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15"

        if let url = URL(string: "https://web.whatsapp.com/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("🔄 Loading started...")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ WhatsApp Web loaded successfully")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Failed to load: \(error.localizedDescription)")
    }
}
