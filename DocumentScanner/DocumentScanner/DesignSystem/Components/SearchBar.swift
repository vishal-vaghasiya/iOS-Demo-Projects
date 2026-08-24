//
//  SearchBar.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: Images.System.search)
                    .foregroundColor(.appTextSecondary)
                
                TextField("", text: $text)
                    .appFont(.appBody, color: .appTextPrimary)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .appFont(.appBody, color: .appTextSecondary)
                    }
                    .submitLabel(.search)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appSecondaryBackground)
            .cornerRadius(10)
        }
    }
}

// Text Field placeholder helper
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    SearchBar(text: .constant(""), placeholder: "Search files...")
        .padding()
}
