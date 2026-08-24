//
//  SectionHeader.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .appFont(.appTitle3, weight: .bold, color: .appTextPrimary)
            
            Spacer()
            
            if let actTitle = actionTitle, let act = action {
                Button(action: act) {
                    Text(actTitle)
                        .appFont(.appCallout, weight: .semibold, color: .appPrimary)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SectionHeader(title: "Recent Files", actionTitle: "See All") {}
        .padding()
}
