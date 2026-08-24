//
//  ImagePicker.swift
//  WoundAI
//
//  Created by Vishal Vaghasiya on 17/04/26.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var image: UIImage?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Text("Select Image")
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }

            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    image = uiImage
                }
            }
        }
    }
}
