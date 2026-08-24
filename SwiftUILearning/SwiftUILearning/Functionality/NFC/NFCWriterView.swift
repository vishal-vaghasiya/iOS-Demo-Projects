//
//  NFCWriterView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 12/11/25.
//

import SwiftUI
import CoreNFC

enum NFCWriteType: String, CaseIterable, Identifiable {
    case text = "Text"
    case url = "URL"
    case json = "JSON"
    var id: String { self.rawValue }
}

struct NFCWriterView: View {
    @StateObject private var writerManager = NFCWriterManager()
    @Environment(\.dismiss) private var dismiss
    @State private var messageToWrite: String = ""
    @State private var selectedType: NFCWriteType = .text

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("NFC Writer")
                    .font(.headline)
                Spacer()
                Spacer().frame(width: 44)
            }
            .padding(.top)

            Spacer()

            if writerManager.isWritten {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    Text("NFC Tag Written Successfully!")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 16) {
                    Picker("Data Type", selection: $selectedType) {
                        ForEach(NFCWriteType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    TextField("Enter message to write", text: $messageToWrite)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        writerManager.beginWriting(messageToWrite, type: selectedType)
                    }) {
                        Label("Write to NFC Tag", systemImage: "pencil.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(messageToWrite.isEmpty)
                    .padding(.horizontal)

                    if writerManager.isWriting {
                        ProgressView("Hold your iPhone near the NFC tag...")
                            .padding()
                    }
                }
            }

            Spacer()
        }
        .padding()
        .alert(isPresented: $writerManager.showErrorAlert) {
            Alert(title: Text("Error"),
                  message: Text(writerManager.errorMessage ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
    }
}

final class NFCWriterManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var isWriting = false
    @Published var isWritten = false
    @Published var showErrorAlert = false
    @Published var errorMessage: String?

    private var session: NFCNDEFReaderSession?
    private var messageToWrite: String?
    private var writeType: NFCWriteType = .text

    func beginWriting(_ message: String, type: NFCWriteType) {
        guard NFCNDEFReaderSession.readingAvailable else {
            errorMessage = "NFC is not available on this device."
            showErrorAlert = true
            return
        }

        messageToWrite = message
        writeType = type
        isWriting = true
        isWritten = false

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near an NFC tag to write data."
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isWriting = false
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Not used for writing
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Session is active
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first, let messageToWrite = messageToWrite else { return }

        session.connect(to: tag) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isWriting = false
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
                session.invalidate()
                return
            }

            tag.queryNDEFStatus { status, _, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.isWriting = false
                        self.errorMessage = error.localizedDescription
                        self.showErrorAlert = true
                    }
                    session.invalidate()
                    return
                }

                guard status == .readWrite else {
                    DispatchQueue.main.async {
                        self.isWriting = false
                        self.errorMessage = "Tag is not writable."
                        self.showErrorAlert = true
                    }
                    session.invalidate()
                    return
                }

                let payload: NFCNDEFPayload
                switch self.writeType {
                case .text:
                    payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: messageToWrite, locale: .current)!
                case .url:
                    payload = NFCNDEFPayload.wellKnownTypeURIPayload(string: messageToWrite)!
                case .json:
                    let jsonData = messageToWrite.data(using: .utf8)!
                    payload = NFCNDEFPayload(format: .media, type: "application/json".data(using: .utf8)!, identifier: Data(), payload: jsonData)
                }

                let message = NFCNDEFMessage(records: [payload])

                tag.writeNDEF(message) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            self.showErrorAlert = true
                        } else {
                            self.isWritten = true
                        }
                        self.isWriting = false
                    }
                    session.invalidate()
                }
            }
        }
    }
}

#Preview {
    NFCWriterView()
}
