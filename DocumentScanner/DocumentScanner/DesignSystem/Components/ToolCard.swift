//
//  ToolCard.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct ToolCard: View {
    let title: String
    let description: String
    let iconName: String
    var tintColor: Color = .appPrimary
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon wrapper
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(tintColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(tintColor)
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .appFont(.appHeadline, weight: .bold, color: .appTextPrimary)
                
                Text(description)
                    .appFont(.appFootnote, color: .appTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appTextSecondary.opacity(0.5))
        }
        .cardStyle(padding: 14)
    }
}

#Preview {
    ToolCard(
        title: "Create PDF",
        description: "Convert photos or text to PDF files",
        iconName: Images.System.createPdf
    )
    .padding()
}
