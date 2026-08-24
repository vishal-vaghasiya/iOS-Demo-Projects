//
//  ContentView.swift
//  NFCPlayground
//
//  Created by Vishal Vaghasiya on 23/01/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = NFCViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                Picker("Payload Type", selection: $viewModel.selectedType) {
                    ForEach(NFCPayloadType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Enter payload", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)

                Button("Write NFC") {
                    viewModel.writeNFC()
                }
                .buttonStyle(.borderedProminent)

                Button("Read NFC") {
                    viewModel.readNFC()
                }
                .buttonStyle(.bordered)

                Text(viewModel.statusMessage)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
            .navigationTitle("NFC Advanced Demo")
        }
    }
}

#Preview {
    ContentView()
}
