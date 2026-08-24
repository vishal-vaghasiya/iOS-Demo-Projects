//
//  NFCReaderView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 12/11/25.
//


import SwiftUI
import CoreNFC
import UIKit

struct NFCReaderView: View {
    @StateObject private var nfcManager = NFCManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("NFC Reader")
                    .font(.headline)
                Spacer()
                Spacer().frame(width: 44)
            }
            .padding(.top)
            
            Spacer()

            if let message = nfcManager.nfcMessage {
                VStack(spacing: 16) {
                    Text("NFC Data")
                        .font(.headline)
                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            UIPasteboard.general.string = message
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: {
                            shareText(message)
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "wave.3.right.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    Text("Tap below to start scanning NFC tag")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        nfcManager.beginScanning()
                    }) {
                        Label("Start Scanning", systemImage: "nfc")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
            }

            Spacer()
        }
        .padding()
        .alert(isPresented: $nfcManager.showErrorAlert) {
            Alert(title: Text("Error"), message: Text(nfcManager.errorMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
        }
    }
    
    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.keyWindow?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}

@MainActor
final class NFCManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var nfcMessage: String?
    @Published var showErrorAlert = false
    @Published var errorMessage: String?
    
    private var session: NFCNDEFReaderSession?

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            errorMessage = "NFC scanning is not available on this device."
            showErrorAlert = true
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the NFC tag."
        session?.begin()
    }
    
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
        return
    }
    
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        Task { @MainActor in
            if let firstMessage = messages.first {
                let payloadTexts = firstMessage.records.compactMap { record -> String? in
                    if let text = String(data: record.payload, encoding: .utf8) {
                        return text
                    }
                    return nil
                }
                self.nfcMessage = payloadTexts.joined(separator: "\n")
            }
        }
    }
}

#Preview {
    NFCReaderView()
}
