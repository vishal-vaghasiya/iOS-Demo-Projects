//
//  ImageConvertView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct ImageConvertView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var selectedFormat: ImageFormat = .jpeg
    @State private var fileName = ""
    
    @State private var isProcessing = false
    @State private var processedResults: [ProcessedFileResult] = []
    @State private var errorMessage: String? = nil
    
    private let imageUseCase = ProcessImageUseCase()
    
    var body: some View {
        VStack(spacing: 0) {
            if !processedResults.isEmpty {
                ProcessedResultsPreviewView(
                    title: "Converted Images Preview",
                    defaultFolderName: outputBaseName,
                    operationIcon: Images.System.convertImage,
                    onDone: { presentationMode.wrappedValue.dismiss() },
                    results: $processedResults
                )
            } else if selectedImages.isEmpty {
                Button(action: { showImagePicker = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: Images.System.convertImage)
                            .font(.system(size: 48))
                            .foregroundColor(.appPrimary)
                        
                        Text("Select Images to Convert")
                            .appFont(.appTitle3, weight: .bold, color: .appPrimary)
                        
                        Text("Select one or more photos to change their file formats.")
                            .appFont(.appBody, color: .appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .cardStyle()
                    .padding()
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Horizontal Preview List
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Selected Photos (\(selectedImages.count))")
                                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                                Spacer()
                                Button("Add More") {
                                    showImagePicker = true
                                }
                                .appFont(.appCallout, weight: .semibold, color: .appPrimary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(selectedImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: selectedImages[index])
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(8)
                                                .clipped()
                                            
                                            Button(action: { selectedImages.remove(at: index) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.6).clipShape(Circle()))
                                                    .padding(2)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal)
                        
                        // Select Target Format
                        VStack(alignment: .leading, spacing: 10) {
                            Text(Strings.ImageTools.selectFormat)
                                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                            
                            Picker("", selection: $selectedFormat) {
                                Text("JPEG").tag(ImageFormat.jpeg)
                                Text("PNG").tag(ImageFormat.png)
                                Text("HEIC").tag(ImageFormat.heic)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.horizontal)
                        
                        // Output filename
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Strings.PDFTools.enterFileName)
                                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                            
                            TextField("e.g. Converted_Photo", text: $fileName)
                                .padding()
                                .background(Color.appCardBackground)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.appSeparator, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        if let errorMsg = errorMessage {
                            Text(errorMsg)
                                .appFont(.appCallout, color: .appError)
                                .padding(.horizontal)
                        }
                        
                        // Action Button
                        if isProcessing {
                            LoadingView(message: "Converting images in batch...")
                                .frame(height: 120)
                        } else {
                            PrimaryButton(
                                title: Strings.ImageTools.convertBtn,
                                iconName: Images.System.convertImage,
                                isEnabled: !selectedImages.isEmpty
                            ) {
                                Task {
                                    await convertImages()
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .navigationTitle(Strings.ImageTools.convertTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
    }

    private var outputBaseName: String {
        fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "converted_image" : fileName
    }
    
    @MainActor
    private func convertImages() async {
        isProcessing = true
        errorMessage = nil
        processedResults.removeAll()
        
        let baseName = outputBaseName
        var index = 1
        
        do {
            var newResults: [ProcessedFileResult] = []
            for uiImage in selectedImages {
                // Use autoreleasepool to prevent memory spike in batch operations (synchronous scope)
                let (name, imageToProcess): (String, UIImage) = autoreleasepool(invoking: {
                    let name = selectedImages.count == 1 ? baseName : "\(baseName)_\(index)"
                    // Create a lightweight copy to limit autoreleased temporaries inside the pool
                    let imageCopy = uiImage
                    return (name, imageCopy)
                })

                let result = try await imageUseCase.prepareConvertedImage(
                    image: imageToProcess,
                    targetFormat: selectedFormat,
                    preferredName: name
                )
                newResults.append(result)
                index += 1
            }
            selectedImages.removeAll()
            processedResults = newResults
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}

#Preview {
    NavigationView {
        ImageConvertView()
    }
}
