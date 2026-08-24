//// QRCodeManager.swift
//import UIKit
//import CoreImage.CIFilterBuiltins
//
//class QRCodeManager {
//    static let shared = QRCodeManager()
//    private let context = CIContext()
//    private let filter = CIFilter.qrCodeGenerator()
//
//    func generateQRCode(from string: String, color: UIColor = .black, logo: UIImage? = nil, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
//        filter.message = Data(string.utf8)
//        guard let outputImage = filter.outputImage else { return nil }
//
//        let transformed = outputImage.transformed(by: CGAffineTransform(scaleX: size.width / outputImage.extent.size.width, y: size.height / outputImage.extent.size.height))
//
//        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
//        colorFilter.setValue(transformed, forKey: kCIInputImageKey)
//        colorFilter.setValue(CIColor(color: color), forKey: "inputColor0")
//        colorFilter.setValue(CIColor(color: .white), forKey: "inputColor1")
//
//        guard let coloredImage = colorFilter.outputImage, let cgImage = context.createCGImage(coloredImage, from: coloredImage.extent) else { return nil }
//
//        var finalImage = UIImage(cgImage: cgImage)
//
//        if let logo = logo {
//            UIGraphicsBeginImageContextWithOptions(finalImage.size, false, UIScreen.main.scale)
//            finalImage.draw(in: CGRect(origin: .zero, size: finalImage.size))
//
//            let logoSize = CGSize(width: finalImage.size.width * 0.2, height: finalImage.size.height * 0.2)
//            let logoOrigin = CGPoint(x: (finalImage.size.width - logoSize.width)/2, y: (finalImage.size.height - logoSize.height)/2)
//            logo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
//
//            finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? finalImage
//            UIGraphicsEndImageContext()
//        }
//
//        return finalImage
//    }
//}
//
//
//// QRCodeGeneratorView.swift
//import SwiftUI
//
//struct QRCodeGeneratorView: View {
//    @State private var textToEncode: String = ""
//    @State private var qrImage: UIImage?
//    @State private var selectedColor: Color = .black
//    @State private var includeLogo: Bool = false
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Enter Text")) {
//                    TextField("Text to encode", text: $textToEncode)
//                }
//
//                Section(header: Text("Options")) {
//                    ColorPicker("QR Color", selection: $selectedColor)
//                    Toggle("Include Logo", isOn: $includeLogo)
//                }
//
//                Section {
//                    Button("Generate QR Code") {
//                        generateQRCode()
//                    }
//                }
//
//                if let image = qrImage {
//                    Section(header: Text("QR Code")) {
//                        Image(uiImage: image)
//                            .resizable()
//                            .interpolation(.none)
//                            .scaledToFit()
//                            .frame(height: 300)
//                            .contextMenu {
//                                Button(action: {
//                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                                }) {
//                                    Text("Save to Photos")
//                                    Image(systemName: "square.and.arrow.down")
//                                }
//                            }
//                    }
//                }
//            }
//            .navigationTitle("QR Generator")
//        }
//    }
//
//    func generateQRCode() {
//        let uiColor = UIColor(selectedColor)
//        let logo = includeLogo ? UIImage(named: "logo") : nil
//        qrImage = QRCodeManager.shared.generateQRCode(from: textToEncode, color: uiColor, logo: logo)
//    }
//}
//
//
//// QRCodeScannerView.swift (uses UIViewControllerRepresentable)
//import SwiftUI
//import AVFoundation
//
//struct QRCodeScannerView: UIViewControllerRepresentable {
//    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
//        var parent: QRCodeScannerView
//
//        init(parent: QRCodeScannerView) {
//            self.parent = parent
//        }
//
//        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
//               let stringValue = metadataObject.stringValue {
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//                parent.completion(stringValue)
//            }
//        }
//    }
//
//    var completion: (String) -> Void
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        let captureSession = AVCaptureSession()
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
//              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
//            return viewController
//        }
//
//        if captureSession.canAddInput(videoInput) {
//            captureSession.addInput(videoInput)
//        }
//
//        let metadataOutput = AVCaptureMetadataOutput()
//        if captureSession.canAddOutput(metadataOutput) {
//            captureSession.addOutput(metadataOutput)
//            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
//            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
//        }
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = UIScreen.main.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        viewController.view.layer.addSublayer(previewLayer)
//
//        captureSession.startRunning()
//
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//}
