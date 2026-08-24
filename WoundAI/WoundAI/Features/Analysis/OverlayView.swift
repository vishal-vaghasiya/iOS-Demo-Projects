//
//  OverlayView.swift
//  WoundAI
//
//  Created by Vishal Vaghasiya on 17/04/26.
//

import SwiftUI

struct OverlayView: View {
    let mask: UIImage

    var body: some View {
        Image(uiImage: mask)
            .resizable()
            .scaledToFit()
            .opacity(0.5)
            .blendMode(.multiply)
    }
}
