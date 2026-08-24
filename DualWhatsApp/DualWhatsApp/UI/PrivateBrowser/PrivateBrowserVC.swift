//
//  PrivateBrowserVC.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 09/10/25.
//

import UIKit
import WebKit
class PrivateBrowserVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - PROPERTY
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Private Browser"
        setupPrivateWebView()
        loadHomePage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self,
            selector: #selector(preventScreenshot),
            name: UIScreen.capturedDidChangeNotification,
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
        WKWebsiteDataStore.nonPersistent().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date.distantPast) {
            print("Private data cleared")
        }
    }
    
    // MARK: - UI SETUP
    private func setupPrivateWebView() {
        // Apply non-persistent configuration to storyboard webView
        webView.configuration.websiteDataStore = .nonPersistent()
        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
    }
    
    private func loadHomePage() {
        if let url = URL(string: "https://www.google.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    @objc func preventScreenshot() {
        if UIScreen.main.isCaptured {
            print("Screen recording detected!")
            webView.isHidden = true
        } else {
            webView.isHidden = false
        }
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
    }

}
extension PrivateBrowserVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page loaded: \(webView.url?.absoluteString ?? "")")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load page: \(error.localizedDescription)")
    }
}
