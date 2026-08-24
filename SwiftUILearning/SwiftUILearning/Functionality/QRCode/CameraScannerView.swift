//
//  CameraScannerView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 31/10/25.
//
import SwiftUI

// MARK: - Camera Scanner View (Safe Main Thread)
struct CameraScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Binding var showScanner: Bool

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, ScannerDelegate {
        var parent: CameraScannerView
        init(parent: CameraScannerView) { self.parent = parent }

        func didFind(code: String) {
            DispatchQueue.main.async {
                self.parent.scannedText = code
                self.parent.showScanner = false
            }
        }
    }
}
