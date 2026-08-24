//
//  BarcodeGeneratorView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 05/11/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct BarcodeGeneratorView: View {
    @State private var inputText: String = ""
    @State private var barcodeImage: UIImage? = nil
    @State private var selectedType: BarcodeType = .code128
    @State private var showShareSheet = false
    @State private var showSavedAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Title
                    Text("Generate a Barcode")
                        .font(.title2.bold())
                        .padding(.top)
                    
                    // Input text
                    TextField("Enter text or number to encode", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    // Barcode type picker
                    Picker("Barcode Type", selection: $selectedType) {
                        ForEach(BarcodeType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Generated barcode preview
                    Group {
                        if let image = barcodeImage {
                            VStack(spacing: 10) {
                                Image(uiImage: image)
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(maxWidth: 300, maxHeight: 150)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                
                                Text("Barcode Preview")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("Your barcode will appear here after generation.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Generate button
                    Button(action: generateBarcode) {
                        Label("Generate Barcode", systemImage: "barcode.viewfinder")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(inputText.isEmpty ? Color.gray.opacity(0.4) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .disabled(inputText.isEmpty)
                    
                    // Action buttons
                    if let image = barcodeImage {
                        HStack(spacing: 20) {
                            Button(action: {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                showSavedAlert = true
                            }) {
                                Label("Save", systemImage: "square.and.arrow.down")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                shareBarcode(image)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                }
                .navigationTitle("Barcode Generator")
                .alert("Saved to Photos!", isPresented: $showSavedAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
        }
    }
    
    // MARK: - Generate Barcode
    private func generateBarcode() {
        let context = CIContext()
        let data = Data(inputText.utf8)
        let filter: CIFilter
        
        switch selectedType {
        case .code128:
            let f = CIFilter.code128BarcodeGenerator()
            f.message = data
            filter = f
        case .pdf417:
            let f = CIFilter.pdf417BarcodeGenerator()
            f.message = data
            filter = f
        case .aztec:
            let f = CIFilter.aztecCodeGenerator()
            f.message = data
            filter = f
        }
        
        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
            if let cgimg = context.createCGImage(scaledImage, from: scaledImage.extent) {
                barcodeImage = UIImage(cgImage: cgimg)
            }
        }
    }
    
    // MARK: - Share Function
    private func shareBarcode(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Barcode Type Enum
enum BarcodeType: CaseIterable {
    case code128, pdf417, aztec
    
    var displayName: String {
        switch self {
        case .code128: return "Code128"
        case .pdf417: return "PDF417"
        case .aztec: return "Aztec"
        }
    }
}

#Preview {
    BarcodeGeneratorView()
}
