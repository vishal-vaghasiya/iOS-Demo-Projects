//
//  BarCodeScannerView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 05/11/25.
//

import SwiftUI
import AVFoundation
import AudioToolbox
import UIKit

struct BarCodeScannerView: View {
    @State private var scannedText = ""
    @State private var showScanner = true
    @State private var showCopiedAlert = false
    
    var body: some View {
        ZStack {
            if showScanner {
                // UIKit bridge to BarcodeScannerViewController
                BarcodeCameraScannerView(scannedValue: $scannedText, showScanner: $showScanner)
                    .ignoresSafeArea()
            } else {
                resultView
            }
        }
        .alert("Copied!", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) { }
        }
        .navigationTitle("Barcode Scanner")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Result View
    private var resultView: some View {
        ScrollView {
            VStack(spacing: 25) {
                Spacer(minLength: 30)
                
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Scanned Barcode")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                
                Text(scannedText)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                // MARK: - Buttons
                VStack(spacing: 15) {
                    Button {
                        UIPasteboard.general.string = scannedText
                        showCopiedAlert = true
                    } label: {
                        Label("Copy Barcode", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        shareBarcode(scannedText)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        showScanner = true
                        scannedText = ""
                    } label: {
                        Label("Rescan", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            AudioServicesPlaySystemSound(SystemSoundID(1057))
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    // MARK: - Share Handler
    private func shareBarcode(_ code: String) {
        let activityVC = UIActivityViewController(activityItems: [code], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    BarCodeScannerView()
}
