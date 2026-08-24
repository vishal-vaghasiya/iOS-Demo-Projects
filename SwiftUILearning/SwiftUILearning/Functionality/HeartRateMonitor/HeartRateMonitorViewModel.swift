//
//  HeartRateMonitorViewModel.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 12/11/25.
//

import Foundation
import AVFoundation
import CoreVideo

final class HeartRateMonitorViewModel: NSObject, ObservableObject {
    @Published var bpm: Int = 0
    @Published var isMonitoring = false
    @Published var fingerDetected = false
    
    private var session: AVCaptureSession?
    private var device: AVCaptureDevice?
    private var redValues: [Double] = []
    private var timeStamps: [TimeInterval] = []
    private var lastPeakTime: TimeInterval = 0
    private var peaks: [TimeInterval] = []
    private let filterWindow = 10
    
    private let processingQueue = DispatchQueue(label: "com.heartrate.cameraQueue")

    // MARK: - Start Monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        bpm = 0
        redValues.removeAll()
        timeStamps.removeAll()
        peaks.removeAll()
        
        setupCamera()
    }

    // MARK: - Stop Monitoring
    func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false
        fingerDetected = false
        session?.stopRunning()
        toggleTorch(on: false)
    }

    // MARK: - Camera Setup
    private func setupCamera() {
        session = AVCaptureSession()
        session?.sessionPreset = .low

        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        device = camera
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session!.canAddInput(input) { session!.addInput(input) }

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: processingQueue)
            if session!.canAddOutput(output) { session!.addOutput(output) }

            try camera.lockForConfiguration()
            camera.torchMode = .on
            camera.videoZoomFactor = 1.5
            camera.unlockForConfiguration()

            session?.startRunning()
            fingerDetected = true
        } catch {
            print("Camera configuration failed: \(error.localizedDescription)")
        }
    }

    private func toggleTorch(on: Bool) {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch control failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension HeartRateMonitorViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)!
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        var redSum: Double = 0.0
        var count = 0
        
        // Average red intensity across sample pixels
        for y in stride(from: 0, to: height, by: 20) {
            for x in stride(from: 0, to: width * 4, by: 40) {
                redSum += Double(buffer[y * bytesPerRow + x])
                count += 1
            }
        }
        
        let avgRed = redSum / Double(count)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        processRedValue(avgRed)
    }

    // MARK: - Signal Processing
    private func processRedValue(_ value: Double) {
        let now = Date().timeIntervalSince1970
        redValues.append(value)
        timeStamps.append(now)

        if redValues.count > 200 {
            redValues.removeFirst()
            timeStamps.removeFirst()
        }

        if redValues.count >= filterWindow {
            let smoothed = redValues.suffix(filterWindow).reduce(0, +) / Double(filterWindow)
            detectPeak(from: smoothed, at: now)
        }
    }

    private func detectPeak(from smoothedValue: Double, at timestamp: TimeInterval) {
        guard let lastValue = redValues.dropLast().last else { return }

        // Detect rising and falling edges (simple peak detection)
        if smoothedValue < lastValue && lastValue > redValues.dropLast(2).last ?? 0 {
            let timeSinceLastPeak = timestamp - lastPeakTime
            if timeSinceLastPeak > 0.4 && timeSinceLastPeak < 2.0 { // Valid heartbeat interval
                peaks.append(timestamp)
                if peaks.count > 5 {
                    let intervals = zip(peaks.dropFirst(), peaks).map { $0.0 - $0.1 }
                    let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
                    let newBPM = Int(60 / avgInterval)
                    DispatchQueue.main.async {
                        self.bpm = newBPM
                    }
                }
            }
            lastPeakTime = timestamp
        }
    }
}
