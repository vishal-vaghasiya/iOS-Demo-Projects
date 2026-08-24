//
//  PDFCompressView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct PDFCompressView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = PDFCompressViewModel()
    
    @State private var showDocumentPicker = false
    @State private var selectedLevel = 1 // 0: Low, 1: Medium, 2: High
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.selectedUrl == nil {
                Button(action: { showDocumentPicker = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: Images.System.compressPdf)
                            .font(.system(size: 48))
                            .foregroundColor(.appPrimary)
                        
                        Text("Select PDF to Compress")
                            .appFont(.appTitle3, weight: .bold, color: .appPrimary)
                        
                        Text("Choose any PDF from your device to reduce its size.")
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
                        // File info
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.appError)
                                .font(.system(size: 28))
                            
                            Text(viewModel.selectedUrl?.lastPathComponent ?? "")
                                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button("Change") {
                                showDocumentPicker = true
                            }
                            .appFont(.appCallout, weight: .semibold, color: .appPrimary)
                        }
                        .cardStyle()
                        .padding(.horizontal)
                        
                        // Presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text(Strings.PDFTools.compressionLevel)
                                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                            
                            Picker("", selection: $selectedLevel) {
                                Text(Strings.PDFTools.lowCompression).tag(0)
                                Text(Strings.PDFTools.mediumCompression).tag(1)
                                Text(Strings.PDFTools.highCompression).tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: selectedLevel) { val in
                                switch val {
                                case 0: viewModel.compressionQuality = 0.8
                                case 1: viewModel.compressionQuality = 0.5
                                case 2: viewModel.compressionQuality = 0.2
                                default: viewModel.compressionQuality = 0.5
                                }
                            }
                            
                            // Info text
                            Text(compressionDetailText)
                                .appFont(.appCaption, color: .appTextSecondary)
                                .padding(.horizontal, 4)
                        }
                        .padding(.horizontal)
                        
                        // Output filename
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Strings.PDFTools.enterFileName)
                                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                            
                            TextField("e.g. Compressed_Document", text: $viewModel.fileName)
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
                                .padding(.horizontal)
                        }
                        
                        if let success = viewModel.successFile {
                            VStack(spacing: 12) {
                                Image(systemName: Images.System.success)
                                    .font(.system(size: 32))
                                    .foregroundColor(.appSuccess)
                                
                                Text("PDF Successfully Compressed!")
                                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                                
                                HStack(spacing: 16) {
                                    VStack {
                                        Text("New Size")
                                            .appFont(.appCaption, color: .appTextSecondary)
                                        Text(ByteCountFormatter.string(fromByteCount: success.fileSize, countStyle: .file))
                                            .appFont(.appBody, weight: .bold, color: .appTextPrimary)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .cardStyle()
                            .padding(.horizontal)
                        }
                        
                        // Compress Action
                        if viewModel.isProcessing {
                            LoadingView(message: "Rebuilding and compressing pages...")
                                .frame(height: 120)
                        } else {
                            PrimaryButton(
                                title: Strings.PDFTools.compressBtn,
                                iconName: Images.System.compressPdf,
                                isEnabled: true
                            ) {
                                Task {
                                    await viewModel.compressPDF()
                                    if viewModel.successFile != nil {
                                        try? await Task.sleep(nanoseconds: 800_000_000)
                                        presentationMode.wrappedValue.dismiss()
                                    }
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
        .navigationTitle(Strings.PDFTools.compressTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedUrls: Binding(
                get: { [] },
                set: { urls in
                    if let first = urls.first {
                        viewModel.selectPDF(url: first)
                    }
                }
            ))
        }
    }
    
    private var compressionDetailText: String {
        switch selectedLevel {
        case 0:
            return "Minimizes compression. Keeps images crisp, but results in a larger file."
        case 1:
            return "Balances file size and image clarity. Recommended for most documents."
        case 2:
            return "Maximizes compression. Reduces document to the smallest possible size, which may lower image clarity."
        default:
            return ""
        }
    }
}

#Preview {
    NavigationView {
        PDFCompressView()
    }
}
