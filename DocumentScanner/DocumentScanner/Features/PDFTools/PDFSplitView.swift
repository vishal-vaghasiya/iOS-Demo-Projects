//
//  PDFSplitView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct PDFSplitView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = PDFSplitViewModel()
    
    @State private var showDocumentPicker = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.selectedUrl == nil {
                // Empty view, click to choose PDF
                Button(action: { showDocumentPicker = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: Images.System.splitPdf)
                            .font(.system(size: 48))
                            .foregroundColor(.appPrimary)
                        
                        Text("Select PDF to Split")
                            .appFont(.appTitle3, weight: .bold, color: .appPrimary)
                        
                        Text("Select a multi-page PDF document to extract pages.")
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
                    VStack(spacing: 20) {
                        // File Metadata Card
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.appError)
                                .font(.system(size: 28))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.selectedUrl?.lastPathComponent ?? "")
                                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                                    .lineLimit(1)
                                
                                Text("\(viewModel.pageCount) Pages")
                                    .appFont(.appCaption, color: .appTextSecondary)
                            }
                            
                            Spacer()
                            
                            Button("Change") {
                                showDocumentPicker = true
                            }
                            .appFont(.appCallout, weight: .semibold, color: .appPrimary)
                        }
                        .cardStyle()
                        .padding(.horizontal)
                        
                        // Select/Deselect All buttons
                        HStack(spacing: 12) {
                            Button("Select All") {
                                viewModel.selectAllPages()
                            }
                            .appFont(.appFootnote, weight: .semibold, color: .appPrimary)
                            
                            Button("Deselect All") {
                                viewModel.deselectAllPages()
                            }
                            .appFont(.appFootnote, weight: .semibold, color: .appTextSecondary)
                            
                            Spacer()
                            
                            Text("\(viewModel.selectedPages.count) Selected")
                                .appFont(.appFootnote, weight: .bold, color: .appTextPrimary)
                        }
                        .padding(.horizontal)
                        
                        // Grid of Pages
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(0..<viewModel.pageCount, id: \.self) { index in
                                let isSelected = viewModel.selectedPages.contains(index)
                                Button(action: { viewModel.togglePageSelection(index: index) }) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color.appSecondaryBackground)
                                                .frame(height: 90)
                                            
                                            Image(systemName: "doc.text")
                                                .font(.system(size: 24))
                                                .foregroundColor(isSelected ? .appPrimary : .appTextSecondary.opacity(0.5))
                                            
                                            if isSelected {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.appPrimary)
                                                    .background(Color.white.clipShape(Circle()))
                                                    .offset(x: 28, y: -30)
                                            }
                                        }
                                        
                                        Text("Page \(index + 1)")
                                            .appFont(.appCaption, weight: .semibold, color: isSelected ? .appPrimary : .appTextPrimary)
                                    }
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Output filename
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Strings.PDFTools.enterFileName)
                                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                            
                            TextField("e.g. Extracted_Report", text: $viewModel.fileName)
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
                                
                                Text("Pages Extracted!")
                                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                                
                                Text("Saved as \(success.name).pdf in Files.")
                                    .appFont(.appCaption, color: .appTextSecondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .cardStyle()
                            .padding(.horizontal)
                        }
                        
                        // Split Action
                        if viewModel.isProcessing {
                            LoadingView(message: "Extracting pages...")
                                .frame(height: 120)
                        } else {
                            PrimaryButton(
                                title: Strings.PDFTools.splitBtn,
                                iconName: Images.System.splitPdf,
                                isEnabled: !viewModel.selectedPages.isEmpty
                            ) {
                                Task {
                                    await viewModel.splitPDF()
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
        .navigationTitle(Strings.PDFTools.splitTitle)
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
}

#Preview {
    NavigationView {
        PDFSplitView()
    }
}
