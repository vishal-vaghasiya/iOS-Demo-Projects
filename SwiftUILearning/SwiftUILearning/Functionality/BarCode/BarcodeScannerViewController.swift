//
//  BarcodeScannerViewController.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 05/11/25.
//

import UIKit
import AVFoundation

protocol BarcodeScannerDelegate: AnyObject {
    func didFind(code: String)
}

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: BarcodeScannerDelegate?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private let cameraPreviewView = UIView()

    private var scanLine: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureCamera()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Wait until overlay and scan line are created
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startScanAnimation()
        }
    }

    private func configureCamera() {
        DispatchQueue.main.async {
            self.captureSession = AVCaptureSession()

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  let session = self.captureSession else {
                print("Camera setup failed.")
                return
            }

            session.beginConfiguration()
            if session.canAddInput(input) { session.addInput(input) }

            let output = AVCaptureMetadataOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.ean13, .ean8, .code128, .aztec, .pdf417, .dataMatrix]
            }
            session.commitConfiguration()

            self.cameraPreviewView.frame = self.view.bounds
            self.view.addSubview(self.cameraPreviewView)

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            preview.frame = self.view.bounds
            self.cameraPreviewView.layer.addSublayer(preview)
            self.previewLayer = preview

            // ✅ Restrict scanning only inside the visible rectangle box
            let scanRectWidth: CGFloat = 300
            let scanRectHeight: CGFloat = 150
            let scanRect = CGRect(
                x: (self.view.bounds.width - scanRectWidth) / 2,
                y: (self.view.bounds.height - scanRectHeight) / 2,
                width: scanRectWidth,
                height: scanRectHeight
            )
            let convertedRect = preview.metadataOutputRectConverted(fromLayerRect: scanRect)
            output.rectOfInterest = convertedRect

            session.startRunning()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                guard let previewLayer = self.previewLayer else { return }
                previewLayer.connection?.videoOrientation = .portrait

                // Define the visible scanning area (same as your overlay box)
                let scanRectWidth: CGFloat = 300
                let scanRectHeight: CGFloat = 150
                let scanRect = CGRect(
                    x: (self.view.bounds.width - scanRectWidth) / 2,
                    y: (self.view.bounds.height - scanRectHeight) / 2,
                    width: scanRectWidth,
                    height: scanRectHeight
                )

                // Convert UI coordinates into camera coordinate space
                let convertedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)

                // Apply safely to the AVCaptureMetadataOutput
                if let session = self.captureSession,
                   let output = session.outputs.first as? AVCaptureMetadataOutput {
                    output.rectOfInterest = convertedRect
                }
            }
            
            self.addScannerOverlay()
        }
    }

    private func addScannerOverlay() {
        // Dimmed overlay background
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isUserInteractionEnabled = false
        view.addSubview(overlayView)

        // Define scanning area
        let scanRectWidth: CGFloat = 300
        let scanRectHeight: CGFloat = 150
        let scanRect = CGRect(
            x: (view.bounds.width - scanRectWidth) / 2,
            y: (view.bounds.height - scanRectHeight) / 2,
            width: scanRectWidth,
            height: scanRectHeight
        )

        // Transparent center (mask)
        let path = UIBezierPath(rect: overlayView.bounds)
        let transparentPath = UIBezierPath(rect: scanRect)
        path.append(transparentPath)
        path.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer

        // ✅ Create a new layer for the red corners ABOVE overlay
        let cornersLayer = CALayer()
        view.layer.addSublayer(cornersLayer)

        // Add rounded red corners
        let cornerLength: CGFloat = 25
        let _: CGFloat = 4
        _ = UIColor.red.cgColor

        func addCorner(x: CGFloat, y: CGFloat, horizontal: Bool, vertical: Bool) {
            let horizontalLine = CAShapeLayer()
            let verticalLine = CAShapeLayer()

            let hPath = UIBezierPath()
            let vPath = UIBezierPath()

            if horizontal && !vertical {
                // Top-left
                hPath.move(to: CGPoint(x: x, y: y))
                hPath.addLine(to: CGPoint(x: x + 25, y: y)) // top edge
                vPath.move(to: CGPoint(x: x, y: y))
                vPath.addLine(to: CGPoint(x: x, y: y + 25)) // left edge
            } else if !horizontal && !vertical {
                // Top-right
                hPath.move(to: CGPoint(x: x + 25, y: y))
                hPath.addLine(to: CGPoint(x: x, y: y)) // top edge
                vPath.move(to: CGPoint(x: x + 25, y: y))
                vPath.addLine(to: CGPoint(x: x + 25, y: y + 25)) // right edge
            } else if horizontal && vertical {
                // Bottom-left
                hPath.move(to: CGPoint(x: x, y: y + 25))
                hPath.addLine(to: CGPoint(x: x + 25, y: y + 25)) // bottom edge
                vPath.move(to: CGPoint(x: x, y: y + 25))
                vPath.addLine(to: CGPoint(x: x, y: y)) // left edge
            } else if !horizontal && vertical {
                // Bottom-right
                hPath.move(to: CGPoint(x: x + 25, y: y + 25))
                hPath.addLine(to: CGPoint(x: x, y: y + 25)) // bottom edge
                vPath.move(to: CGPoint(x: x + 25, y: y + 25))
                vPath.addLine(to: CGPoint(x: x + 25, y: y)) // right edge
            }

            for line in [horizontalLine, verticalLine] {
                line.strokeColor = UIColor.red.cgColor
                line.lineWidth = 4
                line.lineCap = .round
                cornersLayer.addSublayer(line)
            }

            horizontalLine.path = hPath.cgPath
            verticalLine.path = vPath.cgPath
        }

        // 4 corners
        addCorner(x: scanRect.minX, y: scanRect.minY, horizontal: true, vertical: false)
        addCorner(x: scanRect.maxX - cornerLength, y: scanRect.minY, horizontal: false, vertical: false)
        addCorner(x: scanRect.minX, y: scanRect.maxY - cornerLength, horizontal: true, vertical: true)
        addCorner(x: scanRect.maxX - cornerLength, y: scanRect.maxY - cornerLength, horizontal: false, vertical: true)

        // Red scanning line with glow
        let line = UIView(frame: CGRect(x: scanRect.minX, y: scanRect.minY, width: scanRect.width, height: 2))
        line.backgroundColor = .red
        line.layer.shadowColor = UIColor.red.cgColor
        line.layer.shadowOpacity = 1.0
        line.layer.shadowRadius = 10
        line.layer.shadowOffset = CGSize(width: 0, height: 0)
        line.layer.zPosition = 999
        view.addSubview(line)
        self.scanLine = line
    }

    private func startScanAnimation() {
        guard let scanLine = scanLine else { return }

        let startY = (view.bounds.height - 150) / 2
        let endY = startY + 150 - 2

        scanLine.isHidden = false
        scanLine.layer.removeAllAnimations()
        scanLine.frame.origin.y = startY

        UIView.animateKeyframes(withDuration: 2.5, delay: 0, options: [.repeat, .autoreverse, .calculationModeLinear]) {
            // Move line down and intensify shadow
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                scanLine.frame.origin.y = endY
                scanLine.layer.shadowOpacity = 1.0
                scanLine.layer.shadowRadius = 12
            }

            // Move line up and fade shadow
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                scanLine.frame.origin.y = startY
                scanLine.layer.shadowOpacity = 0.5
                scanLine.layer.shadowRadius = 4
            }
        }
    }

    private func stopScanAnimation() {
        guard let scanLine = scanLine else { return }
        scanLine.layer.removeAllAnimations()
        scanLine.isHidden = true
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = obj.stringValue else { return }
        captureSession?.stopRunning()
        self.stopScanAnimation()
        delegate?.didFind(code: code)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}
