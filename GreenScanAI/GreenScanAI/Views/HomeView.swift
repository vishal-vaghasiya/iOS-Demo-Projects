//
//  HomeView.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import SwiftUI
import Photos
import AVFoundation

struct HomeView: View {

    @StateObject private var viewModel = PlantScanViewModel()
    @State private var showPicker = false
    @State private var sourceType: ImageSourceType = .camera
    @State private var navigateToResult = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                if viewModel.isLoading {
                    ProgressView("Analyzing...")
                }

                if let plant = viewModel.plant {
                    Text("🌱 \(plant.commonName)")
                }

                if let disease = viewModel.disease {
                    Text("🦠 \(disease.name)")
                }

                Button("Scan from Camera") {
                    requestCameraPermission()
                }

                Button("Select from Gallery") {
                    requestPhotoPermission()
                }
            }
            .sheet(isPresented: $showPicker) {
                ImagePicker(
                    sourceType: sourceType.uiKitSource
                ) { image in
                    viewModel.scan(image: image)
                }
            }
            .onChange(of: viewModel.plant != nil) { _, hasPlant in
                if hasPlant {
                    navigateToResult = true
                }
            }
            .padding()
            .navigationDestination(isPresented: $navigateToResult) {
                if let plant = viewModel.plant {
                    ResultView(
                        plant: plant,
                        disease: viewModel.disease
                    )
                }
            }
        }
    }

    private func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sourceType = .camera
            showPicker = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        sourceType = .camera
                        showPicker = true
                    }
                }
            }

        case .denied, .restricted:
            print("❌ Camera permission denied")

        @unknown default:
            break
        }
    }

    private func requestPhotoPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            sourceType = .photoLibrary
            showPicker = true

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        sourceType = .photoLibrary
                        showPicker = true
                    }
                }
            }

        case .denied, .restricted:
            print("❌ Photo library permission denied")

        @unknown default:
            break
        }
    }
}

#Preview {
    HomeView()
}
