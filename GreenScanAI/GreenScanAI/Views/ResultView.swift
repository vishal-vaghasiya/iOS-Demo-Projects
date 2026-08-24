//
//  ResultView.swift
//  GreenScanAI
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import SwiftUI

struct ResultView: View {
    let plant: PlantModel
    let disease: DiseaseModel?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Plant Name
                Text(plant.commonName)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Scientific Name
                Text(plant.fullScientificName ?? plant.scientificName)
                    .font(.title3)
                    .foregroundColor(.secondary)

                // Confidence
                HStack {
                    Text("Confidence")
                    Spacer()
                    Text("\(Int(plant.confidence * 100))%")
                        .fontWeight(.semibold)
                }
                .padding()
                .background(Color.green.opacity(0.15))
                .cornerRadius(12)

                // Confidence Warning
                if plant.confidence < 0.3 {
                    Text("⚠️ Low confidence result. Try another image.")
                        .foregroundColor(.orange)
                        .font(.footnote)
                }

                // Remaining Requests
                if let remaining = plant.remainingRequests {
                    HStack {
                        Text("Remaining scans")
                        Spacer()
                        Text("\(remaining)")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(12)
                }
                
                NavigationLink {
                    DetailView(
                        plant: plant,
                        disease: disease
                    )
                } label: {
                    Text("View Details")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ResultView(
        plant: PlantModel(
            commonName: "Kumquat",
            scientificName: "Citrus japonica",
            confidence: 0.5,
            fullScientificName: "Citrus japonica Thunb.",
            remainingRequests: 499
        ),
        disease: nil
    )
}
