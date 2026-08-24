//
//  PDFSecurityView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct PDFSecurityView: View {
    @Environment(\.presentationMode) var presentationMode

    private enum SecurityMode: Int, CaseIterable, Identifiable {
        case protect
        case removeProtect

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .protect:
                return Strings.PDFTools.protectMode
            case .removeProtect:
                return Strings.PDFTools.removeProtectMode
            }
        }

        var emptyStateText: String {
            switch self {
            case .protect:
                return "Add a secure password lock to your PDF documents."
            case .removeProtect:
                return "Unlock a password-protected PDF and save an unprotected copy."
            }
        }

        var passwordLabel: String {
            switch self {
            case .protect:
                return Strings.PDFTools.enterPassword
            case .removeProtect:
                return "Current PDF Password"
            }
        }

        var fileNamePlaceholder: String {
            switch self {
            case .protect:
                return "e.g. Locked_Document"
            case .removeProtect:
                return "e.g. Unlocked_Document"
            }
        }

        var defaultFileName: String {
            switch self {
            case .protect:
                return "secured_document"
            case .removeProtect:
                return "unlocked_document"
            }
        }

        var buttonTitle: String {
            switch self {
            case .protect:
                return Strings.PDFTools.protectBtn
            case .removeProtect:
                return Strings.PDFTools.removeProtectBtn
            }
        }

        var iconName: String {
            switch self {
            case .protect:
                return Images.System.protectPdf
            case .removeProtect:
                return Images.System.removeProtectPdf
            }
        }

        var loadingMessage: String {
            switch self {
            case .protect:
                return "Encrypting document..."
            case .removeProtect:
                return "Unlocking document..."
            }
        }

        var successTitle: String {
            switch self {
            case .protect:
                return "PDF Password Applied!"
            case .removeProtect:
                return "PDF Password Removed!"
            }
        }

        func successMessage(for file: SavedFile) -> String {
            switch self {
            case .protect:
                return "Saved as \(file.name).pdf. This file is now encrypted."
            case .removeProtect:
                return "Saved as \(file.name).pdf. This file is now unlocked."
            }
        }
    }

    @State private var selectedMode: SecurityMode = .protect
    @State private var selectedUrl: URL? = nil
    @State private var showDocumentPicker = false

    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fileName = ""

    @State private var isProcessing = false
    @State private var successFile: SavedFile? = nil
    @State private var errorMessage: String? = nil

    private let pdfUseCase = ProcessPDFUseCase()

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedMode) {
                ForEach(SecurityMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedMode) { _ in
                resetModeState()
            }

            if selectedUrl == nil {
                Button(action: { showDocumentPicker = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: selectedMode.iconName)
                            .font(.system(size: 48))
                            .foregroundColor(.appPrimary)

                        Text(selectedMode.title)
                            .appFont(.appTitle3, weight: .bold, color: .appPrimary)

                        Text(selectedMode.emptyStateText)
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

                            Text(selectedUrl?.lastPathComponent ?? "")
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

                        // Password Form
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Strings.General.options)
                                .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text(selectedMode.passwordLabel)
                                    .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                                SecureField("", text: $password)
                                    .padding()
                                    .background(Color.appCardBackground)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.appSeparator, lineWidth: 1)
                                    )
                            }

                            // Confirm Password Field
                            if selectedMode == .protect {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(Strings.PDFTools.confirmPassword)
                                        .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                                    SecureField("", text: $confirmPassword)
                                        .padding()
                                        .background(Color.appCardBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.appSeparator, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Output filename
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Strings.PDFTools.enterFileName)
                                .appFont(.appCallout, weight: .bold, color: .appTextSecondary)

                            TextField(selectedMode.fileNamePlaceholder, text: $fileName)
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

                                Text(selectedMode.successTitle)
                                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)

                                Text(selectedMode.successMessage(for: success))
                                    .appFont(.appCaption, color: .appTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .cardStyle()
                            .padding(.horizontal)
                        }

                        // Protect Action
                        if isProcessing {
                            LoadingView(message: selectedMode.loadingMessage)
                                .frame(height: 120)
                        } else {
                            PrimaryButton(
                                title: selectedMode.buttonTitle,
                                iconName: selectedMode.iconName,
                                isEnabled: isFormValid
                            ) {
                                Task {
                                    await applySecurity()
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
        .navigationTitle(Strings.PDFTools.securityTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedUrls: Binding(
                get: { [] },
                set: { urls in
                    if let first = urls.first {
                        selectedUrl = first
                        resetModeState()
                        successFile = nil
                        errorMessage = nil
                    }
                }
            ), allowsMultipleSelection: false)
        }
    }

    private var isFormValid: Bool {
        switch selectedMode {
        case .protect:
            return !password.isEmpty && password == confirmPassword
        case .removeProtect:
            return !password.isEmpty
        }
    }

    private func resetModeState() {
        password = ""
        confirmPassword = ""
        fileName = ""
        successFile = nil
        errorMessage = nil
    }

    @MainActor
    private func applySecurity() async {
        guard let url = selectedUrl else { return }

        if password.isEmpty {
            errorMessage = Strings.PDFTools.passwordEmptyError
            return
        }
        if selectedMode == .protect && password != confirmPassword {
            errorMessage = Strings.PDFTools.passwordsDoNotMatch
            return
        }

        isProcessing = true
        errorMessage = nil
        successFile = nil

        let preferredName = fileName.trimmingCharacters(in: .whitespaces).isEmpty ? selectedMode.defaultFileName : fileName

        do {
            let savedFile: SavedFile
            switch selectedMode {
            case .protect:
                savedFile = try await pdfUseCase.passwordProtectPDF(url: url, password: password, preferredName: preferredName)
            case .removeProtect:
                savedFile = try await pdfUseCase.removePasswordProtection(url: url, password: password, preferredName: preferredName)
            }
            successFile = savedFile
            password = ""
            confirmPassword = ""
            fileName = ""
            dismissAfterSuccessfulSave()
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    private func dismissAfterSuccessfulSave() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NavigationView {
        PDFSecurityView()
    }
}
