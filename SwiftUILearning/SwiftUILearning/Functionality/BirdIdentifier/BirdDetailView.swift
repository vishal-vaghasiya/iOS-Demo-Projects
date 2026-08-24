//
//  BirdDetailView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 28/10/25.
//

import SwiftUI
import AVFoundation

struct BirdDetailView: View {
    let result: BirdInfo

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
    let mockBird = BirdInfo(
        name: "Peregrine Falcon",
        scientificName: "Falco peregrinus",
        description: "The Peregrine Falcon is known as the fastest bird in the world, capable of reaching speeds over 300 km/h during its hunting stoop.",
        imageURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/6/66/Falco_peregrinus_tethered.jpg"),
        wikiURL: URL(string: "https://en.wikipedia.org/wiki/Peregrine_falcon")
    )
    return NavigationStack {
        BirdDetailView(result: mockBird)
    }
}
