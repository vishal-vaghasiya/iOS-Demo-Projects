//
//  PlantDetailView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 28/10/25.
//

import SwiftUI

struct PlantDetailView: View {
    let result: PlantInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageURL = result.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                }

                Text(result.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Scientific name: \(result.scientificName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(result.description)
                    .font(.body)
                    .padding(.top, 8)

                if let wikiURL = result.wikiURL {
                    Link("Read more on Wikipedia", destination: wikiURL)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle(result.name)
    }
}
#Preview {
    let mockPlant = PlantInfo(
        name: "Rose",
        scientificName: "Rosa",
        description: "Roses are a group of herbaceous shrubs found in temperate regions throughout both hemispheres. They are loved for their beautiful flowers and sweet fragrance.",
        imageURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/a/a3/Rosa_rubiginosa_mit_einigen_Knospen-2.jpg"),
        wikiURL: URL(string: "https://en.wikipedia.org/wiki/Rose")
    )
    return NavigationStack {
        PlantDetailView(result: mockPlant)
    }
}
