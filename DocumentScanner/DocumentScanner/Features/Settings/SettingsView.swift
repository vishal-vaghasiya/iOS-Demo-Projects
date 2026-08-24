//
//  SettingsView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var emailToast = false
    
    var body: some View {
        Form {
            // Appearance Section
            Section(header: Text(Strings.Settings.appearanceLabel)) {
                HStack {
                    Label(Strings.Settings.lightModeOnly, systemImage: "sun.max.fill")
                        .foregroundColor(.appWarning)
                    Spacer()
                    Text("Forced")
                        .appFont(.appFootnote, color: .appTextSecondary)
                }
            }
            
            // Support Section
            Section(header: Text(Strings.Settings.aboutSection)) {
                Button(action: contactSupport) {
                    HStack {
                        Label(Strings.Settings.contactSupport, systemImage: Images.System.support)
                            .foregroundColor(.appPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary.opacity(0.5))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Legal Section
            Section(header: Text(Strings.Settings.legalSection)) {
                Link(destination: AppConstants.privacyPolicyURL) {
                    HStack {
                        Label(Strings.Settings.privacyPolicy, systemImage: Images.System.privacy)
                            .foregroundColor(.appPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary.opacity(0.5))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Link(destination: AppConstants.termsOfUseURL) {
                    HStack {
                        Label(Strings.Settings.termsOfUse, systemImage: Images.System.terms)
                            .foregroundColor(.appPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary.opacity(0.5))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Version Info Section
            Section {
                HStack {
                    Label(Strings.Settings.versionLabel, systemImage: Images.System.info)
                        .foregroundColor(.appTextSecondary)
                    Spacer()
                    Text("v\(AppConstants.appVersion) (\(AppConstants.appBuild))")
                        .appFont(.appFootnote, color: .appTextSecondary)
                }
            } footer: {
                Text("© 2026 Amit Ghinaiya. All rights reserved.")
                    .font(.caption2)
                    .foregroundColor(.appTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
        }
        .navigationTitle(Strings.Settings.title)
        .overlay(
            VStack {
                Spacer()
                if emailToast {
                    Text("Support email copied to clipboard")
                        .appFont(.appFootnote, weight: .bold, color: .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.appTextPrimary.opacity(0.85))
                        .cornerRadius(20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
            }
        )
    }
    
    private func contactSupport() {
        let mailUrl = URL(string: "mailto:\(AppConstants.supportEmail)")!
        if UIApplication.shared.canOpenURL(mailUrl) {
            UIApplication.shared.open(mailUrl)
        } else {
            // Copy to clipboard fallback if Mail app isn't setup
            UIPasteboard.general.string = AppConstants.supportEmail
            withAnimation {
                emailToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    emailToast = false
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
