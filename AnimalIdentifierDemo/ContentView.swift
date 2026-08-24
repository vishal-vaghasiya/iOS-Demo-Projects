import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @StateObject private var vm = IdentifierViewModel()
    @State private var showPicker = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = vm.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 350)
                        .cornerRadius(12)
                        .padding()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.95))
                        .frame(height: 300)
                        .overlay(Text("Pick an image of an animal"))
                        .padding()
                }

                HStack {
                    Button(action: { showPicker = true }) {
                        Label("Pick Photo", systemImage: "photo")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)

                    Button(action: vm.identify) {
                        Label("Identify", systemImage: "magnifyingglass.circle")
                    }
                    .disabled(vm.uiImage == nil)
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }

                if vm.isLoading {
                    ProgressView("Contacting Clarifai…")
                        .padding()
                }

                if !vm.results.isEmpty {
                    List {
                        Section(header: Text("Predictions")) {
                            ForEach(vm.results, id: \.name) { r in
                                NavigationLink {
                                    DetailView(term: r.name)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(r.name)
                                                .font(.headline)
                                            Text(String(format: "Confidence: %.1f%%", r.confidence * 100))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                }
            }
            .navigationTitle("Animal Identifier")
            .photosPicker(isPresented: $showPicker, selection: $vm.photoItem, matching: .images)
            .onChange(of: vm.photoItem) { _ in vm.loadImageFromPicker() }
            .padding(.bottom)
        }
    }
}
