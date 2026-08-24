//
//  BarcodeCameraScannerView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 04/11/25.
//
import AVFoundation
import SwiftUI

struct BarcodeCameraScannerView: UIViewControllerRepresentable {
    @Binding var scannedValue: String
    @Binding var showScanner: Bool

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let vc = BarcodeScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, BarcodeScannerDelegate {
        var parent: BarcodeCameraScannerView

        init(parent: BarcodeCameraScannerView) {
            self.parent = parent
        }

        func didFind(code: String) {
            DispatchQueue.main.async {
                self.parent.scannedValue = code
                self.parent.showScanner = false
            }
        }
    }
}
