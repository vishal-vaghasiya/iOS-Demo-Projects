//
//  PDFMergeView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct PDFMergeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = PDFMergeViewModel()
    
    @State private var showDocumentPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.selectedUrls.isEmpty {
                // Empty Picker View
                Button(action: { showDocumentPicker = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: Images.System.mergePdf)
                            .font(.system(size: 48))
                            .foregroundColor(.appPrimary)
                        
                        Text(Strings.PDFTools.selectPdfFiles)
                            .appFont(.appTitle3, weight: .bold, color: .appPrimary)
                        
                        Text("Select 2 or more PDF files from your device to merge them.")
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
                // List of picked documents
                VStack(spacing: 16) {
                    HStack {
                        Text(Strings.PDFTools.dragToReorder)
                            .appFont(.appFootnote, color: .appTextSecondary)
                        Spacer()
                        Button(action: { showDocumentPicker = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: Images.System.add)
                                Text("Add")
                            }
                            .appFont(.appCallout, weight: .bold, color: .appPrimary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    List {
                        ForEach(viewModel.selectedUrls.indices, id: \.self) { index in
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.appError)
                                    .font(.system(size: 20))
                                
                                Text(viewModel.selectedUrls[index].lastPathComponent)
                                    .appFont(.appBody, weight: .semibold, color: .appTextPrimary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Image(systemName: Images.System.drag)
                                    .foregroundColor(.appTextSecondary.opacity(0.5))
                            }
                            .listRowBackground(Color.appCardBackground)
                        }
                        .onDelete { indices in
                            for index in indices {
                                viewModel.remove(at: index)
                            }
                        }
                        .onMove { source, dest in
                            viewModel.move(from: source, to: dest)
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    // Name Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.PDFTools.enterFileName)
                            .appFont(.appCallout, weight: .bold, color: .appTextSecondary)
                        
                        TextField("e.g. Merged_Document", text: $viewModel.fileName)
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
                            
                            Text("Merged PDF Created!")
                                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                            
                            Text("Saved as \(success.name).pdf in Files.")
                                .appFont(.appCaption, color: .appTextSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cardStyle()
                        .padding(.horizontal)
                    }
                    
                    // Action Button
                    if viewModel.isProcessing {
                        LoadingView(message: "Merging documents...")
                            .frame(height: 120)
                    } else {
                        PrimaryButton(
                            title: Strings.PDFTools.mergeBtn,
                            iconName: Images.System.mergePdf,
                            isEnabled: viewModel.selectedUrls.count >= 2
                        ) {
                            Task {
                                await viewModel.mergePDFs()
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
            }
        }
        .navigationTitle(Strings.PDFTools.mergeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedUrls: $viewModel.selectedUrls)
        }
    }
}

#Preview {
    NavigationView {
        PDFMergeView()
    }
}
