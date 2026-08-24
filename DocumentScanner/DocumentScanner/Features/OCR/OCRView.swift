//
//  OCRView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct OCRView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = OCRViewModel()
    
    let startWithCamera: Bool
    
    @State private var showImagePicker = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var showSaveAlert = false
    @State private var saveName = ""
    @State private var toastMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.selectedImage == nil {
                // Initial Select Image layout
                VStack(spacing: 20) {
                    Image(systemName: Images.System.imageToText)
                        .font(.system(size: 64))
                        .foregroundColor(.appPrimary)
                    
                    Text(Strings.OCR.selectSource)
                        .appFont(.appTitle2, weight: .bold, color: .appTextPrimary)
                    
                    Text("Select a photo from library or capture a document to recognize and extract text.")
                        .appFont(.appBody, color: .appTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        PrimaryButton(title: "Camera Capture", iconName: Images.System.camera) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                pickerSourceType = .camera
                                showImagePicker = true
                            } else {
                                viewModel.errorMessage = "Camera is not available on this device/simulator."
                            }
                        }
                        
                        SecondaryButton(title: "Photo Library", iconName: Images.System.photoLibrary) {
                            pickerSourceType = .photoLibrary
                            showImagePicker = true
                        }
                    }
                    .padding(.top, 12)
                }
                .padding()
                .cardStyle()
                .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Image Preview
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: viewModel.selectedImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                                .cardStyle(padding: 4)
                            
                            Button(action: {
                                viewModel.selectedImage = nil
                                viewModel.recognizedText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.6).clipShape(Circle()))
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Extract / Loading Actions
                        if viewModel.isProcessing {
                            LoadingView(message: "Extracting text using OCR...")
                                .frame(height: 120)
                        } else if viewModel.recognizedText.isEmpty {
                            PrimaryButton(title: Strings.OCR.recognizeBtn, iconName: Images.System.imageToText) {
                                Task {
                                    await viewModel.runOCR()
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            // Text result container
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(Strings.OCR.recognizedTextLabel)
                                        .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                                    
                                    Spacer()
                                    
                                    // Copy Button
                                    Button(action: {
                                        viewModel.copyToClipboard()
                                        showToast(message: Strings.OCR.copySuccess)
                                    }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.appPrimary)
                                    }
                                    .frame(width: 32, height: 32)
                                }
                                
                                TextEditor(text: $viewModel.recognizedText)
                                    .appFont(.appBody, color: .appTextPrimary)
                                    .frame(height: 200)
                                    .padding(6)
                                    .background(Color.appSecondaryBackground)
                                    .cornerRadius(8)
                            }
                            .cardStyle()
                            .padding(.horizontal)
                            
                            // Action Panel (Share / Save)
                            HStack(spacing: 12) {
                                // Share Button
                                ShareLink(item: viewModel.recognizedText) {
                                    HStack {
                                        Image(systemName: Images.System.share)
                                        Text(Strings.General.share)
                                    }
                                    .appFont(.appCallout, weight: .semibold, color: .appPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.appSecondaryBackground)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.appSeparator, lineWidth: 1)
                                    )
                                }
                                
                                // Save Button
                                Button(action: {
                                    saveName = "OCR_Result"
                                    showSaveAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: Images.System.filesTab)
                                        Text(Strings.General.save)
                                    }
                                    .appFont(.appCallout, weight: .semibold, color: .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.appPrimary)
                                    .cornerRadius(10)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            .padding(.horizontal)
                        }
                        
                        if let errorMsg = viewModel.errorMessage {
                            Text(errorMsg)
                                .appFont(.appCallout, color: .appError)
                                .padding()
                        }
                        
                        if let success = viewModel.successFile {
                            VStack(spacing: 10) {
                                Image(systemName: Images.System.success)
                                    .foregroundColor(.appSuccess)
                                    .font(.system(size: 28))
                                Text("Saved: \(success.name).txt")
                                    .appFont(.appHeadline, weight: .semibold, color: .appTextPrimary)
                            }
                            .padding()
                            .cardStyle()
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            
            // Toast alert
            if let toast = toastMessage {
                Text(toast)
                    .appFont(.appFootnote, weight: .bold, color: .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.appTextPrimary.opacity(0.85))
                    .cornerRadius(20)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(Strings.OCR.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if startWithCamera && viewModel.selectedImage == nil {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    pickerSourceType = .camera
                    showImagePicker = true
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            SingleImagePicker(selectedImage: $viewModel.selectedImage, sourceType: pickerSourceType)
        }
        .alert("Save Text File", isPresented: $showSaveAlert) {
            TextField("", text: $saveName)
            Button(Strings.General.cancel, role: .cancel) {}
            Button(Strings.General.save) {
                if !saveName.trimmingCharacters(in: .whitespaces).isEmpty {
                    viewModel.saveOCRResult(preferredName: saveName)
                    if viewModel.successFile != nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func showToast(message: String) {
        withAnimation {
            toastMessage = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                toastMessage = nil
            }
        }
    }
}

// SwiftUI 3 ShareLink polyfill for iOS 15
struct ShareLink<Content: View>: View {
    let item: String
    @ViewBuilder let label: () -> Content
    @State private var showShareSheet = false
    
    var body: some View {
        Button(action: { showShareSheet = true }) {
            label()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [item])
        }
    }
}

#Preview {
    NavigationView {
        OCRView(startWithCamera: false)
    }
}
