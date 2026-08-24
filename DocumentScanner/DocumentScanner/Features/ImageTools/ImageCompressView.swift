//
//  ImageCompressView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct ImageCompressView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var quality: Double = 0.7
    @State private var fileName = ""
    @State private var selectedFormat: ImageFormat = .jpeg
    
    @State private var isProcessing = false
    @State private var successFile: SavedFile? = nil
    @State private var errorMessage: String? = nil
    
    private let imageUseCase = ProcessImageUseCase()
    
    var body: some View {
        VStack(spacing: 0) {
            if selectedImage == nil {
                Button(action: { showImagePicker = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: Images.System.compressImage)
                            .font(.system(size: 48))
                            .foregroundColor(.appPrimary)
                        
                        Text("Select Image to Compress")
                            .appFont(.appTitle3, weight: .bold, color: .appPrimary)
                        
                        Text("Select a photo from your library to reduce its file size.")
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
                        // Side-by-side or single Preview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Before / After Preview")
                                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                            
                            HStack(spacing: 12) {
                                Image(uiImage: selectedImage!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 180)
                                    .cornerRadius(8)
                                    .cardStyle(padding: 4)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Metadata comparison
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(Strings.ImageTools.originalSize)
                                    .appFont(.appBody, color: .appTextSecondary)
                                Spacer()
                                Text(formattedOriginalSize)
                                    .appFont(.appBody, weight: .bold, color: .appTextPrimary)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text(Strings.ImageTools.targetSize)
                                    .appFont(.appBody, color: .appTextSecondary)
                                Spacer()
                                Text(formattedTargetSize)
                                    .appFont(.appBody, weight: .bold, color: .appPrimary)
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal)
                        
                        // Quality Slider
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(Strings.ImageTools.qualitySlider)
                                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                                Spacer()
                                Text("\(Int(quality * 100))%")
                                    .appFont(.appCallout, weight: .bold, color: .appPrimary)
                            }
                            
                            Slider(value: $quality, in: 0.1...1.0, step: 0.05)
                                .accentColor(.appPrimary)
                        }
                        .padding(.horizontal)
                        
                        // Output format
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
                            
                            TextField("e.g. Compressed_Photo", text: $fileName)
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
                        
                        if let success = successFile {
                            VStack(spacing: 12) {
                                Image(systemName: Images.System.success)
                                    .font(.system(size: 32))
                                    .foregroundColor(.appSuccess)
                                
                                Text("Image Successfully Saved!")
                                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                                
                                Text("Saved as \(success.name).\(success.fileType) in Files.")
                                    .appFont(.appCaption, color: .appTextSecondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .cardStyle()
                            .padding(.horizontal)
                        }
                        
                        // Action Button
                        if isProcessing {
                            LoadingView(message: "Compressing and saving image...")
                                .frame(height: 120)
                        } else {
                            PrimaryButton(
                                title: Strings.ImageTools.compressBtn,
                                iconName: Images.System.compressImage,
                                isEnabled: true
                            ) {
                                Task {
                                    await compressAndSave()
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
        .navigationTitle(Strings.ImageTools.compressTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            SingleImagePicker(selectedImage: $selectedImage, sourceType: pickerSourceType)
        }
    }
    
    private var formattedOriginalSize: String {
        guard let img = selectedImage else { return "0 KB" }
        // Estimate size using JPG representation at 1.0 quality
        let bytes = img.jpegData(compressionQuality: 1.0)?.count ?? 0
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
    
    private var formattedTargetSize: String {
        guard let img = selectedImage else { return "0 KB" }
        if selectedFormat == .png {
            let bytes = img.pngData()?.count ?? 0
            return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
        }
        let bytes = Double(img.jpegData(compressionQuality: 1.0)?.count ?? 0) * quality * (selectedFormat == .heic ? 0.6 : 0.95)
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
    
    @MainActor
    private func compressAndSave() async {
        guard let img = selectedImage else { return }
        
        isProcessing = true
        errorMessage = nil
        successFile = nil
        
        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? "compressed_image" : fileName
        
        do {
            let file = try await imageUseCase.compressImage(
                image: img,
                quality: CGFloat(quality),
                format: selectedFormat,
                preferredName: preferredName
            )
            successFile = file
            // Auto-dismiss after success to avoid duplicate operations
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 800_000_000)
                presentationMode.wrappedValue.dismiss()
            }
            fileName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}

#Preview {
    NavigationView {
        ImageCompressView()
    }
}
