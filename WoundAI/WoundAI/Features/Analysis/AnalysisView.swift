//
//  AnalysisView.swift
//  WoundAI
//
//  Created by Vishal Vaghasiya on 17/04/26.
//

import SwiftUI

struct AnalysisView: View {
    @State private var image: UIImage?
    @State private var mask: UIImage?
    @State private var prediction: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Image Preview
                ZStack {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(12)

                        if let mask {
                            OverlayView(mask: mask)
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipped()
                                .cornerRadius(12)
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 250)
                            .overlay(
                                Text("No Image Selected")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .padding(.horizontal)

                // Picker
                ImagePicker(image: $image)

                // Analyze Button / Loader
                if isLoading {
                    ProgressView("Analyzing...")
                } else {
                    Button(action: runInference) {
                        Text(image == nil ? "Select Image First" : "Analyze")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(image == nil ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(image == nil)
                }

                // Result
                if let prediction {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Result")
                            .font(.headline)

                        Text(prediction)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    private func runInference() {
        guard let image else { return }

        isLoading = true

        Task {
            if let mask = try? await ModelManager.shared.segment(image: image) {
                self.mask = mask
            }

            if let result = try? ModelManager.shared.classify(patch: image) {
                self.prediction = result
            }

            isLoading = false
        }
    }
}

#Preview {
    AnalysisView()
}
