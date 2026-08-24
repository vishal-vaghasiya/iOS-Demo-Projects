//
//  NFCViewModel.swift
//  NFCPlayground
//
//  Created by Vishal Vaghasiya on 23/01/26.
//

import Foundation
import Combine

final class NFCViewModel: ObservableObject {

    @Published var inputText: String = ""
    @Published var selectedType: NFCPayloadType = .text
    @Published var statusMessage: String = "Ready"

    private let nfcService = NFCService()

    init() {
        nfcService.onMessage = { [weak self] message in
            DispatchQueue.main.async {
                self?.statusMessage = message
            }
        }
    }

    func writeNFC() {
        guard NFCValidator.validate(inputText) else {
            statusMessage = "Invalid input"
            return
        }

        do {
            let message = try NFCPayloadBuilder.build(
                type: selectedType,
                input: inputText
            )
            statusMessage = "Writing NFC..."
            nfcService.write(message)
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func readNFC() {
        statusMessage = "Reading NFC..."
        nfcService.read()
    }
}
