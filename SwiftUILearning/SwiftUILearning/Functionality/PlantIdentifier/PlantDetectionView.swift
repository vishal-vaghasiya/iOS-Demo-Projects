//
//  PlantDetectionView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 28/10/25.
//

import SwiftUI
import PhotosUI

struct PlantDetectionView: View {
    @StateObject private var viewModel = PlantDetectionViewModel()
    @State private var showResult = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.selectedImages.count > 0 {
                    // Preview Selected Images
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    PhotosPicker(selection: $viewModel.selectedItems, maxSelectionCount: 4, matching: .images) {
                        Label("Select Plant Photos", systemImage: "photo.on.rectangle.angled")
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
                    ProgressView("Identifying Plant...")
                }
                
                Button(action: {
                    Task {
                        await viewModel.identifyPlant()
                        if viewModel.result != nil {
                            showResult = true
                        }
                    }
                }) {
                    Label("Identify Plant", systemImage: "magnifyingglass")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .allowsHitTesting(!(viewModel.selectedImages.isEmpty || viewModel.isLoading))
                .opacity(viewModel.selectedImages.isEmpty || viewModel.isLoading ? 0.6 : 1.0)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $showResult) {
                if let result = viewModel.result {
                    PlantDetailView(result: result)
                }
            }
        }
    }
}


#Preview {
    PlantDetectionView()
}
