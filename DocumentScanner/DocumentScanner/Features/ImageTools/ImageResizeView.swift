//
//  ImageResizeView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct ImageResizeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var widthString = ""
    @State private var heightString = ""
    @State private var keepAspectRatio = true
    @State private var selectedFormat: ImageFormat = .jpeg
    @State private var fileName = ""
    
    @State private var originalWidth: CGFloat = 0
    @State private var originalHeight: CGFloat = 0
    
    @State private var isProcessing = false
    @State private var successFile: SavedFile? = nil
    @State private var errorMessage: String? = nil
    
    private let imageUseCase = ProcessImageUseCase()
    
    var body: some View {
        VStack(spacing: 0) {
            if selectedImage == nil {
                Button(action: { showImagePicker = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: Images.System.resizeImage)
                            .font(.system(size: 48))
                            .foregroundColor(.appPrimary)
                        
                        Text("Select Image to Resize")
                            .appFont(.appTitle3, weight: .bold, color: .appPrimary)
                        
                        Text("Select a photo to adjust its height and width dimensions.")
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
                        // Details and preview
                        HStack(spacing: 16) {
                            Image(uiImage: selectedImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Original Dimensions")
                                    .appFont(.appCaption, color: .appTextSecondary)
                                Text("\(Int(originalWidth)) x \(Int(originalHeight)) px")
                                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                            }
                            
                            Spacer()
                            
                            Button("Change") {
                                showImagePicker = true
                            }
                            .appFont(.appCallout, weight: .semibold, color: .appPrimary)
                        }
                        .cardStyle()
                        .padding(.horizontal)
                        
                        // Dimensions Input Fields
                        VStack(alignment: .leading, spacing: 14) {
                            Text("New Dimensions")
                                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                            
                            HStack(spacing: 16) {
                                // Width
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(Strings.ImageTools.widthLabel)
                                        .appFont(.appCaption, color: .appTextSecondary)
                                    TextField("Width", text: $widthString)
                                        .keyboardType(.numberPad)
                                        .padding(12)
                                        .background(Color.appSecondaryBackground)
                                        .cornerRadius(8)
                                        .onChange(of: widthString) { val in
                                            updateHeightFromWidth(val)
                                        }
                                }
                                
                                // Height
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(Strings.ImageTools.heightLabel)
                                        .appFont(.appCaption, color: .appTextSecondary)
                                    TextField("Height", text: $heightString)
                                        .keyboardType(.numberPad)
                                        .padding(12)
                                        .background(Color.appSecondaryBackground)
                                        .cornerRadius(8)
                                        .onChange(of: heightString) { val in
                                            updateWidthFromHeight(val)
                                        }
                                }
                            }
                            
                            // Aspect Ratio Toggle
                            Toggle(isOn: $keepAspectRatio) {
                                Text(Strings.ImageTools.lockAspectRatio)
                                    .appFont(.appBody, weight: .medium, color: .appTextPrimary)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .appPrimary))
                        }
                        .cardStyle()
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
                            
                            TextField("e.g. Resized_Photo", text: $fileName)
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
                                
                                Text("Image Resized Successfully!")
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
                            LoadingView(message: "Resizing image canvas...")
                                .frame(height: 120)
                        } else {
                            PrimaryButton(
                                title: Strings.ImageTools.resizeBtn,
                                iconName: Images.System.resizeImage,
                                isEnabled: isFormValid
                            ) {
                                Task {
                                    await resizeAndSave()
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
        .navigationTitle(Strings.ImageTools.resizeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            SingleImagePicker(selectedImage: Binding(
                get: { selectedImage },
                set: { img in
                    if let image = img {
                        selectedImage = image
                        originalWidth = image.size.width
                        originalHeight = image.size.height
                        widthString = "\(Int(image.size.width))"
                        heightString = "\(Int(image.size.height))"
                        successFile = nil
                        errorMessage = nil
                    }
                }
            ), sourceType: pickerSourceType)
        }
    }
    
    private var isFormValid: Bool {
        guard let w = Double(widthString), let h = Double(heightString) else { return false }
        return w > 0 && h > 0
    }
    
    private func updateHeightFromWidth(_ widthVal: String) {
        guard keepAspectRatio, originalWidth > 0 else { return }
        guard let widthDouble = Double(widthVal) else { return }
        let aspect = originalHeight / originalWidth
        let newHeight = Int(widthDouble * aspect)
        let newHeightString = "\(newHeight)"
        if heightString != newHeightString {
            heightString = newHeightString
        }
    }
    
    private func updateWidthFromHeight(_ heightVal: String) {
        guard keepAspectRatio, originalHeight > 0 else { return }
        guard let heightDouble = Double(heightVal) else { return }
        let aspect = originalWidth / originalHeight
        let newWidth = Int(heightDouble * aspect)
        let newWidthString = "\(newWidth)"
        if widthString != newWidthString {
            widthString = newWidthString
        }
    }
    
    @MainActor
    private func resizeAndSave() async {
        guard let img = selectedImage,
              let w = Double(widthString),
              let h = Double(heightString) else { return }
        
        isProcessing = true
        errorMessage = nil
        successFile = nil
        
        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? "resized_image" : fileName
        
        do {
            let file = try await imageUseCase.resizeImage(
                image: img,
                width: CGFloat(w),
                height: CGFloat(h),
                keepAspectRatio: keepAspectRatio,
                format: selectedFormat,
                preferredName: preferredName
            )
            successFile = file
            fileName = ""
            try? await Task.sleep(nanoseconds: 800_000_000)
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
}

#Preview {
    NavigationView {
        ImageResizeView()
    }
}
