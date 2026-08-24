//
//  DocumentScannerView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI
import VisionKit
import AVFoundation

enum ScanType {
    case document
    case idCard
    case passport
    case receipt
    case businessCard
    
    var title: String {
        switch self {
        case .document: return Strings.Dashboard.scanDoc
        case .idCard: return Strings.Dashboard.scanId
        case .passport: return Strings.Dashboard.scanPassport
        case .receipt: return Strings.Dashboard.scanReceipt
        case .businessCard: return Strings.Dashboard.scanBusinessCard
        }
    }

    var iconName: String {
        switch self {
        case .document: return Images.System.scanDoc
        case .idCard: return Images.System.scanId
        case .passport: return Images.System.scanPassport
        case .receipt: return Images.System.scanReceipt
        case .businessCard: return Images.System.scanBusinessCard
        }
    }

    var guidanceText: String {
        switch self {
        case .document:
            return "Align the document in the frame. The scanner will automatically detect edges, crop, and enhance the document."
        case .idCard:
            return "Align the ID card in the frame. Scan the front and back as separate pages when needed."
        case .passport:
            return "Align the passport page in the frame. Keep text and photo details clear for a clean PDF."
        case .receipt:
            return "Align the full receipt in the frame. For long receipts, scan each section as a separate page."
        case .businessCard:
            return "Align the business card in the frame. Scan front and back as separate pages when needed."
        }
    }

    var fileNamePrefix: String {
        switch self {
        case .document: return "Document_Scan"
        case .idCard: return "ID_Card_Scan"
        case .passport: return "Passport_Scan"
        case .receipt: return "Receipt_Scan"
        case .businessCard: return "Business_Card_Scan"
        }
    }
}

struct DocumentScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    let scanType: ScanType
    
    @State private var scannedImages: [UIImage] = []
    @State private var isProcessing = false
    @State private var successFile: SavedFile? = nil
    @State private var errorMessage: String? = nil
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    
    private let pdfUseCase = ProcessPDFUseCase()
    
    var body: some View {
        VStack {
            if isProcessing {
                LoadingView(message: "Processing scans and generating PDF...")
            } else if let success = successFile {
                VStack(spacing: 20) {
                    Image(systemName: Images.System.success)
                        .font(.system(size: 48))
                        .foregroundColor(.appSuccess)
                    
                    Text("Scan Completed!")
                        .appFont(.appTitle2, weight: .bold, color: .appTextPrimary)
                    
                    Text("Saved as: \(success.name).pdf")
                        .appFont(.appBody, color: .appTextSecondary)
                    
                    PrimaryButton(title: Strings.General.done) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.top)
                }
                .padding()
                .cardStyle()
                .padding()
            } else if let errorMsg = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: Images.System.error)
                        .font(.system(size: 48))
                        .foregroundColor(.appError)
                    
                    Text("Scan Failed")
                        .appFont(.appTitle2, weight: .bold, color: .appTextPrimary)
                    
                    Text(errorMsg)
                        .appFont(.appBody, color: .appTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    SecondaryButton(title: "Try Again") {
                        errorMessage = nil
                        startScanningFlow()
                    }
                    .padding(.top)
                }
                .padding()
                .cardStyle()
                .padding()
            } else {
                // Initial State: Explains and requests camera launch
                VStack(spacing: 24) {
                    Image(systemName: scanType.iconName)
                        .font(.system(size: 64))
                        .foregroundColor(.appPrimary)
                    
                    Text("Scan using Camera")
                        .appFont(.appTitle2, weight: .bold, color: .appTextPrimary)
                    
                    Text(scanType.guidanceText)
                        .appFont(.appBody, color: .appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    PrimaryButton(title: "Start Scanning", iconName: Images.System.camera) {
                        startScanningFlow()
                    }
                }
                .padding()
                .cardStyle()
                .padding()
            }
        }
        .navigationTitle(scanType.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCamera) {
            VisionKitScannerRepresentable(scannedImages: $scannedImages, errorMessage: $errorMessage) {
                showCamera = false
                if !scannedImages.isEmpty {
                    Task {
                        await processScannedImages()
                    }
                }
            }
        }
        .alert("Camera Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }

            Button(Strings.General.cancel, role: .cancel) {}
        } message: {
            Text("Please allow camera access from Settings to scan documents.")
        }
    }
    
    private func startScanningFlow() {
        guard VisionKitScannerRepresentable.isCameraAvailable() else {
            errorMessage = "Camera/Scanner is not available on this device (or you are running in the iOS Simulator). Please use a physical iOS device."
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCamera = true
                    } else {
                        errorMessage = "Camera permission is required to scan documents. Please enable Camera access in Settings."
                    }
                }
            }

        case .denied, .restricted:
            errorMessage = "Camera permission is required to scan documents. Please enable Camera access in Settings."
            showPermissionAlert = true

        @unknown default:
            errorMessage = "Unable to access camera."
        }
    }
    
    @MainActor
    private func processScannedImages() async {
        isProcessing = true
        errorMessage = nil
        
        let preferredName = "\(scanType.fileNamePrefix)_\(Int(Date().timeIntervalSince1970))"
        
        do {
            let file = try await pdfUseCase.createPDFFromImages(images: scannedImages, preferredName: preferredName)
            successFile = file
            try? await Task.sleep(nanoseconds: 800_000_000)
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}

// UIViewControllerRepresentable wrapper over VNDocumentCameraViewController
struct VisionKitScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedImages: [UIImage]
    @Binding var errorMessage: String?
    var onCompletion: () -> Void
    
    static func isCameraAvailable() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return VNDocumentCameraViewController.isSupported
        #endif
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: VisionKitScannerRepresentable
        
        init(_ parent: VisionKitScannerRepresentable) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            parent.scannedImages = images
            parent.onCompletion()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.onCompletion()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.errorMessage = error.localizedDescription
            parent.onCompletion()
        }
    }
}
