//
//  ImageCompressorView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 27/10/25.
//

import SwiftUI
import PhotosUI

struct ImageCompressorView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var compressedImages: [Data] = []
    @State private var isCompressing = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Image Compressor")
                    .font(.title)
                    .bold()
                    .padding(.top)

                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Label("Select Images", systemImage: "photo.on.rectangle.angled")
                            .font(.headline)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                    }
                    .padding()
                }

                if isCompressing {
                    ProgressView("Compressing Images...")
                        .padding()
                }

                Button(action: {
                    Task {
                        await compressImages()
                    }
                }) {
                    Label("Compress Selected Images", systemImage: "arrow.down.circle")
                        .padding()
                        .background(selectedImages.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedImages.isEmpty)
                .padding()

                NavigationLink(
                    destination: ImageCompressPreView(compressedImages: compressedImages),
                    isActive: Binding(
                        get: { !compressedImages.isEmpty },
                        set: { _ in }
                    )
                ) {
                    EmptyView()
                }
            }
            .padding()
            .onChange(of: selectedItems) { newItems in
                Task {
                    selectedImages.removeAll()
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImages.append(uiImage)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Compression Function
    func compressImages() async {
        guard !selectedImages.isEmpty else { return }
        isCompressing = true
        compressedImages.removeAll()

        for image in selectedImages {
            if let compressedData = compressImage(image) {
                compressedImages.append(compressedData)
            }
        }

        isCompressing = false
    }

    // MARK: - Adaptive Compression Algorithm
    func compressImage(_ image: UIImage) -> Data? {
        // Start with high quality
        var compression: CGFloat = 0.9
        guard var imageData = image.jpegData(compressionQuality: compression) else { return nil }

        let originalSize = imageData.count
        let imageSizeMB = Double(originalSize) / (1024.0 * 1024.0)

        // Adjust compression ratio dynamically based on image size
        if imageSizeMB > 5 {
            compression = 0.4 // Strong compression for very large images
        } else if imageSizeMB > 3 {
            compression = 0.6
        } else if imageSizeMB > 1 {
            compression = 0.75
        } else {
            compression = 0.9 // Keep quality high for small images
        }

        imageData = image.jpegData(compressionQuality: compression) ?? imageData
        return imageData
    }
}

#Preview {
    ImageCompressorView()
}
