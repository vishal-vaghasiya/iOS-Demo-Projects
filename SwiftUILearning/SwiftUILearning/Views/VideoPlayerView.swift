//
//  VideoPlayerView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 05/04/25.
//

import SwiftUI
import AVKit
struct VideoPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    let mediaURL: URL? = Bundle.main.url(forResource: "JeevJoy", withExtension: "mp4")
    @State var title : String = "Video Player"
    
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: true) {
                dismiss()
            }
            ZStack{
                if let url = mediaURL{
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(maxWidth: .infinity, maxHeight: 200, alignment: .center)
                        .padding(.top, -10) // Shift form upward to remove 10pt gap
                }else{
                    Text("Not Found")
                }
            }.background(Color.black)
            Spacer()
        }
            .navigationBarHidden(true) // Hide on this screen
    }
}

#Preview {
    VideoPlayerView()
}
