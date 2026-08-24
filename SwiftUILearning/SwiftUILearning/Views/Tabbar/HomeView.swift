//
//  HomeView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 19/06/25.
//

import SwiftUI

struct HomeView: View {
    @State var title : String = "Home"
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: false)
            Spacer()
            Text("Welcome to Home")
            Spacer()
        }.navigationBarHidden(true) // Hide on this screen
    }
}

#Preview {
    HomeView()
}
