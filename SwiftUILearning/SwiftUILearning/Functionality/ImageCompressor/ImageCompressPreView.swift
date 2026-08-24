//
//  ImageCompressPreView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 27/10/25.
//

import SwiftUI

struct ImageCompressPreView: View {
    @Environment(\.dismiss) private var dismiss
    var compressedImages: [Data]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                ForEach(compressedImages.indices, id: \.self) { index in
                    if let uiImage = UIImage(data: compressedImages[index]) {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                            
                            Text("\(getImageSizeString(from: compressedImages[index]))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            HStack(spacing: 20) {
                Button(action: {
                    // Save all compressed images to Photo Library and go to Home
                    for data in compressedImages {
                        if let image = UIImage(data: data) {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }
                    }
                    // Navigate back to Home after saving
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }) {
                    Label("Save to Gallery", systemImage: "square.and.arrow.down")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    // Share compressed images
                    let images = compressedImages.compactMap { UIImage(data: $0) }
                    guard !images.isEmpty else { return }

                    let activityVC = UIActivityViewController(activityItems: images, applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(activityVC, animated: true, completion: nil)
                    }
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    // Navigate back to Home
                    dismiss()
                }) {
                    Label("Home", systemImage: "house.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding()
        }
        .navigationTitle("Compressed Images")
    }

    // Helper function to calculate image size in KB
    func getImageSizeString(from data: Data) -> String {
        let kbSize = Double(data.count) / 1024.0
        return String(format: "%.1f KB", kbSize)
    }
}

#Preview {
    ImageCompressPreView(compressedImages: [])
}
