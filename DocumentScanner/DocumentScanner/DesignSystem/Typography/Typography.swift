//
//  Typography.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

extension Font {
    /// Large Title (Dynamic Type size for main headers, e.g., 34pt default)
    static let appLargeTitle = Font.system(.largeTitle)
    
    /// Title 1 (Dynamic Type size for screen titles, e.g., 28pt default)
    static let appTitle = Font.system(.title)
    
    /// Title 2 (Dynamic Type size for major section headers, e.g., 22pt default)
    static let appTitle2 = Font.system(.title2)
    
    /// Title 3 (Dynamic Type size for card headers, e.g., 20pt default)
    static let appTitle3 = Font.system(.title3)
    
    /// Headline (Dynamic Type size for emphasized text, e.g., 17pt default bold)
    static let appHeadline = Font.system(.headline)
    
    /// Body (Dynamic Type size for regular readable text, e.g., 17pt default)
    static let appBody = Font.system(.body)
    
    /// Callout (Dynamic Type size for callout notes, e.g., 16pt default)
    static let appCallout = Font.system(.callout)
    
    /// Footnote (Dynamic Type size for subtext or minor labels, e.g., 13pt default)
    static let appFootnote = Font.system(.footnote)
    
    /// Caption (Dynamic Type size for small metadata, e.g., 12pt default)
    static let appCaption = Font.system(.caption)
}

struct AppFontModifier: ViewModifier {
    var font: Font
    var weight: Font.Weight
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .fontWeight(weight)
            .foregroundColor(color)
    }
}

extension View {
    /// Applies a centralized design system typography style, ensuring dynamic type and consistent colors.
    func appFont(_ font: Font, weight: Font.Weight = .regular, color: Color = .appTextPrimary) -> some View {
        self.modifier(AppFontModifier(font: font, weight: weight, color: color))
    }
}
