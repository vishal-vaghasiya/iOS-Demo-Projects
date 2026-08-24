import SwiftUI

struct DetailView: View {

    let plant: PlantModel
    let disease: DiseaseModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Plant Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plant Information")
                        .font(.headline)

                    Text(plant.commonName)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(plant.fullScientificName ?? plant.scientificName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("Confidence")
                        Spacer()
                        Text("\(Int(plant.confidence * 100))%")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.12))
                .cornerRadius(12)

                // MARK: - Disease Section
                if let disease = disease {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Disease Detection")
                            .font(.headline)

                        Text(disease.name)
                            .font(.title3)
                            .fontWeight(.semibold)

                        HStack {
                            Text("Confidence")
                            Spacer()
                            Text("\(Int(disease.confidence * 100))%")
                                .fontWeight(.semibold)
                        }

                        Divider()

                        Text("Treatment")
                            .font(.headline)

                        Text(disease.treatment)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    VStack {
                        Text("No disease detected")
                            .foregroundColor(.green)
                            .font(.headline)

                        Text("Your plant looks healthy 🎉")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(12)
                }

                // MARK: - Remaining Requests
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
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView(
        plant: PlantModel(
            commonName: "Kumquat",
            scientificName: "Citrus japonica",
            confidence: 0.5,
            fullScientificName: "Citrus japonica Thunb.",
            remainingRequests: 499
        ),
        disease: DiseaseModel(
            name: "Leaf Spot",
            confidence: 0.88,
            treatment: "Use fungicide and avoid overwatering."
        )
    )
}
