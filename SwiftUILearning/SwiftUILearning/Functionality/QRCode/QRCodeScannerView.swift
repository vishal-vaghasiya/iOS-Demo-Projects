//
//  QRCodeScannerView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 31/10/25.
//

import SwiftUI
import AVFoundation
import Contacts
import ContactsUI

struct QRCodeScannerView: View {
    @State private var scannedText: String = ""
    @State private var detectedType: String = "Loading..."
    @State private var showScanner = true
    @State private var showCopiedAlert = false

    // MARK: - Detect QR Type
    private func detectQRCodeType(from text: String) -> String {
        let lower = text.lowercased()
        if lower.hasPrefix("http://") || lower.hasPrefix("https://") {
            if lower.contains(".pdf") { return "PDF" }
            if lower.contains(".jpg") || lower.contains(".jpeg") || lower.contains(".png") || lower.contains(".gif") { return "Image" }
            if lower.contains("youtube.com") || lower.contains("vimeo.com") { return "Video" }
            if lower.contains("spotify.com") || lower.contains("soundcloud.com") { return "MP3 / Playlist" }
            if lower.contains("linktr.ee") || lower.contains("bio.link") { return "Landing Page" }
            if lower.contains("menu") { return "Menu" }
            if lower.contains("feedback") { return "Feedback" }
            if lower.contains("product") { return "Product" }
            if lower.contains("event") { return "Event" }
            if lower.contains("business.site") { return "Business" }
            if lower.contains("apps.apple.com") || lower.contains("play.google.com") { return "App Link" }
            if lower.contains("coupon") || lower.contains("offer") { return "Coupon" }
            if lower.contains("facebook.com") || lower.contains("instagram.com") ||
                lower.contains("twitter.com") || lower.contains("linkedin.com") || lower.contains("tiktok.com") {
                return "Social Media"
            }
            return "Website"
        }
        if lower.contains("begin:vcard") { return "vCard" }
        if lower.contains("vcardplus") { return "vCard Plus" }
        if lower.hasPrefix("mailto:") { return "Email" }
        if lower.hasPrefix("smsto:") || lower.hasPrefix("sms:") { return "SMS" }
        if lower.hasPrefix("whatsapp:") || lower.contains("wa.me") { return "WhatsApp" }
        if lower.hasPrefix("wifi:") { return "WiFi" }
        if lower.hasPrefix("tel:") { return "Phone" }
        if lower.hasPrefix("geo:") { return "Location" }
        if lower.hasPrefix("upi:") { return "Payment / UPI" }
        if lower.contains("barcode") { return "2D Barcode" }
        return "Text / Unknown"
    }

    // MARK: - Resolve Redirects for Short URLs
    private func resolveRedirectURL(from urlString: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(urlString)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10

        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse,
               let finalURL = httpResponse.url?.absoluteString {
                completion(finalURL)
            } else {
                completion(urlString)
            }
        }
        task.resume()
    }

    var body: some View {
        ZStack {
            if showScanner {
                CameraScannerView(scannedText: $scannedText, showScanner: $showScanner)
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 20) {
                    // Header
                    Text("Scan Result")
                        .font(.title2)
                        .bold()

                    if !scannedText.isEmpty {
                        Text("Detected: \(detectedType)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    ScrollView {
                        VStack(spacing: 15) {
                            switch detectedType {
                            case "Website", "PDF", "App Link", "Landing Page", "Social Media", "Product", "Business", "Event":
                                if let url = URL(string: scannedText) {
                                    Link("Open \(detectedType)", destination: url)
                                        .buttonStyle(.borderedProminent)
                                }

                            case "Image":
                                if let url = URL(string: scannedText) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .cornerRadius(10)
                                    } placeholder: {
                                        ProgressView("Loading image...")
                                    }
                                    .frame(height: 200)
                                }

                            case "Email":
                                if let encoded = scannedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let url = URL(string: encoded) {
                                    Button(action: { UIApplication.shared.open(url) }) {
                                        Label("Send Email", systemImage: "envelope")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }

                            case "SMS":
                                if let encoded = scannedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let url = URL(string: encoded) {
                                    Button(action: { UIApplication.shared.open(url) }) {
                                        Label("Send SMS", systemImage: "message")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }

                            case "WhatsApp":
                                if let encoded = scannedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let url = URL(string: encoded) {
                                    Button(action: { UIApplication.shared.open(url) }) {
                                        Label("Open in WhatsApp", systemImage: "message.fill")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }

                            case "WiFi":
                                if let wifiInfo = parseWiFiInfo(from: scannedText) {
                                    VStack(spacing: 10) {
                                        Text("WiFi Network: \(wifiInfo.ssid)")
                                            .font(.headline)
                                        Button {
                                            joinWiFi(ssid: wifiInfo.ssid, password: wifiInfo.password)
                                        } label: {
                                            Label("Join WiFi", systemImage: "wifi")
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                } else {
                                    Text("WiFi QR Detected.\nConnect manually via WiFi settings.")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                }

                            case "Phone":
                                if let url = URL(string: scannedText) {
                                    Button(action: { UIApplication.shared.open(url) }) {
                                        Label("Call Number", systemImage: "phone.fill")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }

                            case "Location":
                                if let url = URL(string: scannedText) {
                                    Button(action: { UIApplication.shared.open(url) }) {
                                        Label("Open Location", systemImage: "map")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }

                            case "2D Barcode":
                                Text("2D Barcode Detected.\nThis might represent encoded text or data.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)

                            case "vCard":
                                Button {
                                    saveVCard(scannedText)
                                } label: {
                                    Label("Save Contact", systemImage: "person.crop.circle.badge.plus")
                                }
                                .buttonStyle(.borderedProminent)

                            case "vCard Plus":
                                Button {
                                    saveVCard(scannedText)
                                } label: {
                                    Label("Save vCard Plus", systemImage: "person.crop.circle.badge.plus")
                                }
                                .buttonStyle(.borderedProminent)

                            case "Payment / UPI":
                                if let url = URL(string: scannedText) {
                                    Button(action: { UIApplication.shared.open(url) }) {
                                        Label("Pay Now", systemImage: "indianrupeesign.circle.fill")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }

                            case "Menu":
                                if let url = URL(string: scannedText) {
                                    Link("Open Menu", destination: url)
                                        .buttonStyle(.borderedProminent)
                                }

                            case "Feedback":
                                if let url = URL(string: scannedText) {
                                    Link("Open Feedback Form", destination: url)
                                        .buttonStyle(.borderedProminent)
                                }

                            case "Coupon":
                                Text("Coupon Detected! Use this offer:")
                                    .font(.headline)
                                Text(scannedText)
                                    .font(.body)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)

                            case "MP3 / Playlist":
                                if let url = URL(string: scannedText) {
                                    Link("Open Playlist", destination: url)
                                        .buttonStyle(.borderedProminent)
                                }

                            case "Video":
                                if let url = URL(string: scannedText) {
                                    Link("Watch Video", destination: url)
                                        .buttonStyle(.borderedProminent)
                                }

                            case "Text / Unknown":
                                Text(scannedText)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)

                            default:
                                Text(scannedText)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Buttons
                    HStack(spacing: 25) {
                        Button {
                            UIPasteboard.general.string = scannedText
                            showCopiedAlert = true
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            let activityVC = UIActivityViewController(activityItems: [scannedText], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first?.rootViewController {
                                rootVC.present(activityVC, animated: true)
                            }
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)

                        Button("Rescan") {
                            scannedText = ""
                            showScanner = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding()
                .alert("Copied to Clipboard!", isPresented: $showCopiedAlert) {
                    Button("OK", role: .cancel) {}
                }
                .onAppear {
                    if scannedText.lowercased().hasPrefix("http") {
                        resolveRedirectURL(from: scannedText) { resolved in
                            DispatchQueue.main.async {
                                detectedType = detectQRCodeType(from: resolved)
                            }
                        }
                    } else {
                        detectedType = detectQRCodeType(from: scannedText)
                    }
                }
            }
        }
    }
}

// MARK: - Save vCard Function
private func saveVCard(_ vcardString: String) {
    guard let data = vcardString.data(using: .utf8) else {
        print("Invalid vCard data")
        return
    }
    do {
        let contacts = try CNContactVCardSerialization.contacts(with: data)
        if let contact = contacts.first {
            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
            try store.execute(saveRequest)
            print("Contact saved successfully!")
        }
    } catch {
        print("Failed to save vCard: \(error.localizedDescription)")
    }
}

// MARK: - Parse WiFi Info
private func parseWiFiInfo(from text: String) -> (ssid: String, password: String)? {
    // Expected format: WIFI:T:WPA;S:SSID;P:PASSWORD;;
    guard text.lowercased().hasPrefix("wifi:") else { return nil }
    let components = text.components(separatedBy: ";")
    var ssid = ""
    var password = ""
    for comp in components {
        if comp.hasPrefix("S:") {
            ssid = String(comp.dropFirst(2))
        } else if comp.hasPrefix("P:") {
            password = String(comp.dropFirst(2))
        }
    }
    return ssid.isEmpty ? nil : (ssid, password)
}

// MARK: - Join WiFi Network
private func joinWiFi(ssid: String, password: String) {
    let urlString = "App-Prefs:root=WIFI"
    if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else {
        print("Cannot open WiFi settings.")
    }
}

#Preview {
    QRCodeScannerView()
}
