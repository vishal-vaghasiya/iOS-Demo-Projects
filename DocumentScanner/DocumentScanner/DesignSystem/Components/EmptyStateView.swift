//
//  EmptyStateView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

enum StateStyle {
    case empty
    case success
    case error
    
    var iconColor: Color {
        switch self {
        case .empty: return .appTextSecondary
        case .success: return .appSuccess
        case .error: return .appError
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let description: String
    var iconName: String = Images.System.emptyState
    var style: StateStyle = .empty
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(style.iconColor)
                .padding(.bottom, 8)
            
            Text(title)
                .appFont(.appTitle3, weight: .bold, color: .appTextPrimary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .appFont(.appBody, color: .appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let actTitle = actionTitle, let act = action {
                Button(action: act) {
                    Text(actTitle)
                        .appFont(.appCallout, weight: .semibold, color: .white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.appPrimary)
                        .cornerRadius(8)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "No Files Found",
        description: "You haven't converted or compressed any files yet.",
        style: .empty
    )
}
