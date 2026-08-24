//
//  AnimalDetailView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 29/10/25.
//

import SwiftUI

struct AnimalDetailView: View {
    let result: AnimalInfo

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
    let mockAnimal = AnimalInfo(
        name: "African Elephant",
        scientificName: "Loxodonta africana",
        description: "The African elephant is the largest land animal on Earth. They are known for their large ears, tusks, and intelligence.",
        imageURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/3/37/African_Bush_Elephant.jpg"),
        wikiURL: URL(string: "https://en.wikipedia.org/wiki/African_elephant")
    )
    return NavigationStack {
        AnimalDetailView(result: mockAnimal)
    }
}
