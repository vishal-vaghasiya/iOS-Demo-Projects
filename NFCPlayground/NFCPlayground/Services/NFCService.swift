//
//  NFCService.swift
//  NFCPlayground
//
//  Created by Vishal Vaghasiya on 23/01/26.
//

import CoreNFC

final class NFCService: NSObject {

    var onMessage: ((String) -> Void)?
    private var session: NFCNDEFReaderSession?
    private var writeMessage: NFCNDEFMessage?

    func read() {
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session?.alertMessage = "Hold iPhone near NFC tag"
        session?.begin()
    }

    func write(_ message: NFCNDEFMessage) {
        writeMessage = message
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
        session?.alertMessage = "Hold near NFC tag to write"
        session?.begin()
    }
}

extension NFCService: NFCNDEFReaderSessionDelegate {

    func readerSession(_ session: NFCNDEFReaderSession,
                       didDetect tags: [NFCNDEFTag]) {

        guard let tag = tags.first,
              let message = writeMessage else { return }

        session.connect(to: tag) { _ in
            tag.queryNDEFStatus { status, _, _ in
                guard status == .readWrite else {
                    session.invalidate(errorMessage: "Tag not writable")
                    return
                }

                tag.writeNDEF(message) { error in
                    if let error {
                        session.invalidate(errorMessage: error.localizedDescription)
                    } else {
                        self.onMessage?("Write successful")
                        session.invalidate()
                    }
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession,
                       didDetectNDEFs messages: [NFCNDEFMessage]) {

        guard let record = messages.first?.records.first else { return }

        let payload = String(decoding: record.payload, as: UTF8.self)
        onMessage?("Read: \(payload)")
    }

    func readerSession(_ session: NFCNDEFReaderSession,
                       didInvalidateWithError error: Error) {
        onMessage?(error.localizedDescription)
    }
}
