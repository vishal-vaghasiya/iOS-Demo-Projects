//
//  ButtonView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 20/11/25.
//

import SwiftUI

struct ButtonView: View {
    var body: some View {
        
        Spacer()
        Button {

        } label: {
            Text("Get Started")
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.red)
                )
                .glassEffect()
        }
        
        Button {

        } label: {
            Text("Get Started")
                .foregroundColor(.red)
                .padding()
                .glassEffect()
        }
        
        Button {

        } label: {
            Text("Get Started")
                .foregroundColor(.red)
                .padding()
        }
        Spacer()
        
        TabView {
            Text("Home Screen")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            VideoPlayerView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            Text("Profile Screen")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Color.purple)
    }
}

#Preview {
    ButtonView()
}
