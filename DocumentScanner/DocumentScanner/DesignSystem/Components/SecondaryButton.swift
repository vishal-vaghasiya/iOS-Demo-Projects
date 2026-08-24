//
//  SecondaryButton.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    var iconName: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .appFont(.appHeadline, weight: .semibold, color: isEnabled ? Color.appPrimary : Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.appSecondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appSeparator, lineWidth: 1)
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    SecondaryButton(title: "Cancel") {}
        .padding()
}
