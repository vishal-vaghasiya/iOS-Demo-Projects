//
//  PDFCreateView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct PDFCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = PDFCreateViewModel()
    
    @State private var selectedTab = 0 // 0: Images, 1: Text
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Picker
            Picker("", selection: $selectedTab) {
                Text(Strings.PDFTools.fromImages).tag(0)
                Text(Strings.PDFTools.fromText).tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    if selectedTab == 0 {
                        // Images to PDF Layout
                        imagesSection
                    } else {
                        // Text to PDF Layout
                        textSection
                    }
                    
                    // Name Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.PDFTools.enterFileName)
                            .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                        
                        TextField("e.g. My_Report", text: $viewModel.fileName)
                            .padding()
                            .background(Color.appCardBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.appSeparator, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    if let errorMsg = viewModel.errorMessage {
                        Text(errorMsg)
                            .appFont(.appCallout, color: .appError)
                            .padding()
                    }
                    
                    if let success = viewModel.successFile {
                        VStack(spacing: 12) {
                            Image(systemName: Images.System.success)
                                .font(.system(size: 32))
                                .foregroundColor(.appSuccess)
                            
                            Text("Created: \(success.name).pdf")
                                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                            
                            Text("Saved to Documents. You can view it in the Files list.")
                                .appFont(.appCaption, color: .appTextSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cardStyle()
                        .padding(.horizontal)
                    }
                    
                    // Action Button
                    if viewModel.isProcessing {
                        LoadingView(message: Strings.States.processing)
                            .frame(height: 120)
                    } else {
                        PrimaryButton(
                            title: Strings.PDFTools.generatePdf,
                            iconName: Images.System.createPdf,
                            isEnabled: isActionEnabled
                        ) {
                            Task {
                                if selectedTab == 0 {
                                    await viewModel.generatePDFFromImages()
                                } else {
                                    await viewModel.generatePDFFromText()
                                }
                                if viewModel.successFile != nil {
                                    try? await Task.sleep(nanoseconds: 800_000_000)
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(Strings.PDFTools.createTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $viewModel.selectedImages)
        }
    }
    
    private var isActionEnabled: Bool {
        if selectedTab == 0 {
            return !viewModel.selectedImages.isEmpty
        } else {
            return !viewModel.textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    // Images Section
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Images (\(viewModel.selectedImages.count))")
                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                .padding(.horizontal)
            
            if viewModel.selectedImages.isEmpty {
                Button(action: { showImagePicker = true }) {
                    VStack(spacing: 12) {
                        Image(systemName: Images.System.photoLibrary)
                            .font(.system(size: 36))
                            .foregroundColor(.appPrimary)
                        
                        Text("Add Photos")
                            .appFont(.appCallout, weight: .semibold, color: .appPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .cardStyle()
                    .padding(.horizontal)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Add More Button
                        Button(action: { showImagePicker = true }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.appPrimary)
                                Text("Add More")
                                    .appFont(.appCaption, weight: .semibold, color: .appPrimary)
                            }
                            .frame(width: 90, height: 120)
                            .background(Color.appSecondaryBackground)
                            .cornerRadius(10)
                        }
                        
                        ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: viewModel.selectedImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 90, height: 120)
                                    .cornerRadius(10)
                                    .clipped()
                                
                                Button(action: { viewModel.removeImage(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6).clipShape(Circle()))
                                        .padding(4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Text Section
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Document Header Title")
                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                .padding(.horizontal)
            
            TextField("e.g. Project Specs", text: $viewModel.docTitle)
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appSeparator, lineWidth: 1)
                )
                .padding(.horizontal)
            
            Text("Content Text")
                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                .padding(.horizontal)
            
            TextEditor(text: $viewModel.textInput)
                .frame(height: 180)
                .padding(8)
                .background(Color.appCardBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appSeparator, lineWidth: 1)
                )
                .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationView {
        PDFCreateView()
    }
}
