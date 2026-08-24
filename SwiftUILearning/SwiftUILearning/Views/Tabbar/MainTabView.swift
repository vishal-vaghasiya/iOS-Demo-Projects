//
//  MainTabView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 19/06/25.
//

import SwiftUI

struct MainTabView: View {
    @State var title : String = "Tab View"
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Int = 0
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Home")
                    }
                    .tag(0)

                SearchView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)

                ProfileView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                        Text("Profile")
                    }
                    .tag(2)
            }
            .accentColor(.red) // Active tab tint color
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MainTabView()
}
