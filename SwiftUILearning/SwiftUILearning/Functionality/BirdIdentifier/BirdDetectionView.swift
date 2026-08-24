//
//  BirdDetectionView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 28/10/25.
//

import SwiftUI
import PhotosUI

struct BirdDetectionView: View {
    @StateObject private var viewModel = BirdDetectionViewModel()
    @State private var showResult = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(10)
                        .padding(.horizontal)
                } else {
                    PhotosPicker(selection: $viewModel.selectedItems, maxSelectionCount: 1, matching: .images) {
                        Label("Select Bird Photo", systemImage: "photo.on.rectangle.angled")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView("Identifying Bird...")
                }
                
                Button(action: {
                    Task {
                        await viewModel.identifyBird()
                        if viewModel.result != nil {
                            showResult = true
                        }
                    }
                }) {
                    Label("Identify Bird", systemImage: "magnifyingglass")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .allowsHitTesting(!(viewModel.isLoading || viewModel.selectedImage == nil))
                .opacity(viewModel.isLoading || viewModel.selectedImage == nil ? 0.6 : 1.0)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $showResult) {
                if let result = viewModel.result {
                    BirdDetailView(result: result)
                }
            }
        }
    }
}
#Preview {
    BirdDetectionView()
}
