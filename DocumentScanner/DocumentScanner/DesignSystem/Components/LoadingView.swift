//
//  LoadingView.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .appPrimary))
                .scaleEffect(1.5)
            
            Text(message)
                .appFont(.appCallout, weight: .medium, color: .appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .shadow(color: Color.appTextPrimary.opacity(0.08), radius: 12, x: 0, y: 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SkeletonRow: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appSecondaryBackground)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appSecondaryBackground)
                    .frame(width: 160, height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appSecondaryBackground)
                    .frame(width: 90, height: 10)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.appCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appSeparator, lineWidth: 1)
        )
        .opacity(isAnimating ? 0.4 : 0.85)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct SkeletonListView: View {
    var count: Int = 4
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonRow()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView(message: "Converting images to PDF...")
        SkeletonListView()
    }
}
