//
//  CardModifier.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.appCardBackground)
            .cornerRadius(12)
            .shadow(color: Color.appTextPrimary.opacity(0.04), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appSeparator, lineWidth: 1)
            )
    }
}

extension View {
    /// Applies a premium card layout with card backgrounds, soft borders, and shadows.
    func cardStyle(padding: CGFloat = 16) -> some View {
        self.modifier(CardModifier(padding: padding))
    }
}
