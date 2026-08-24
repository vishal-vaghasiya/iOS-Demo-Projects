//
//  QRCodeGeneratorView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 31/10/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct QRCodeGeneratorView: View {
    @State private var inputText: String = ""
    @State private var selectedType: QRType = .text
    @State private var generatedImage: UIImage?
    @State private var showShareSheet = false
    @State private var showSavedAlert = false
    
    @State private var vcardPhone: String = ""
    @State private var vcardEmail: String = ""
    @State private var wifiName: String = ""
    @State private var wifiPassword: String = ""
    
    enum QRType: String, CaseIterable, Identifiable {
        case text = "Text"
        case url = "URL"
        case email = "Email"
        case vcard = "vCard"
        case wifi = "WiFi"
        var id: String { rawValue }
    }
    
    // MARK: - Dynamic Placeholder
    private var placeholderText: String {
        switch selectedType {
        case .text:
            return "Enter your message or note"
        case .url:
            return "Enter website URL (e.g. https://example.com)"
        case .email:
            return "Enter email address (e.g. name@example.com)"
        case .vcard:
            return "Enter full name"
        case .wifi:
            return "Enter WiFi name (SSID)"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("QRCode Generator")
                    .font(.title2)
                    .bold()
                
                Picker("Type", selection: $selectedType) {
                    ForEach(QRType.allCases) { type in
                        Text(type.rawValue)
                            .tag(type)
                            .fontWeight(selectedType == type ? .bold : .regular)
                            .padding(5)
                            .background(selectedType == type ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(6)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .zIndex(1)
                
                Group {
                    switch selectedType {
                    case .text, .url, .email:
                        TextField(placeholderText, text: $inputText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                    case .vcard:
                        VStack(spacing: 10) {
                            TextField("Full Name", text: $inputText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Phone", text: $vcardPhone)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Email", text: $vcardEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)

                    case .wifi:
                        VStack(spacing: 10) {
                            TextField("WiFi Name (SSID)", text: $wifiName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            SecureField("Password", text: $wifiPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                    }
                }
                
                Button("Generate QR Code") {
                    hideKeyboard()
                    generatedImage = generateQRCode()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                
                if let image = generatedImage {
                    VStack(spacing: 15) {
                        Image(uiImage: image)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .contextMenu {
                                Button("Save to Photos") {
                                    saveToGallery(image)
                                }
                                Button("Share QR Code") {
                                    showShareSheet = true
                                }
                            }
                        
                        HStack {
                            Button("Save") {
                                saveToGallery(image)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Share") {
                                showShareSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                if let image = generatedImage {
                    ShareSheet(activityItems: [image])
                }
            }
            .alert("Saved to Photos", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    // MARK: - Generate QR Code (High Resolution)
    private func generateQRCode() -> UIImage? {
        let content = formattedInput().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return nil }

        // Create QR filter
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(content.utf8)
        filter.setValue(data, forKey: "inputMessage")

        guard let outputImage = filter.outputImage else { return nil }

        // Generate high-resolution QR (1024x1024)
        let targetSize: CGFloat = 1024
        let scaleX = targetSize / outputImage.extent.size.width
        let scaleY = targetSize / outputImage.extent.size.height
        let transformed = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else { return nil }

        // Return crisp, non-blurry UIImage
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
    
    // MARK: - Format Input
    private func formattedInput() -> String {
        switch selectedType {
        case .text:
            return inputText
        case .url:
            return inputText.lowercased().hasPrefix("http") ? inputText : "https://\(inputText)"
        case .email:
            return "mailto:\(inputText)"
        case .vcard:
            return """
            BEGIN:VCARD
            VERSION:3.0
            N:\(inputText)
            TEL;CELL:\(vcardPhone)
            EMAIL:\(vcardEmail)
            END:VCARD
            """
        case .wifi:
            return "WIFI:T:WPA;S:\(wifiName);P:\(wifiPassword);;"
        }
    }
    
    // MARK: - Save QR to Gallery
    private func saveToGallery(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSavedAlert = true
    }
    // MARK: - Hide Keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    QRCodeGeneratorView()
}
