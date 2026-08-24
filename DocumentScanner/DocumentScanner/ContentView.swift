//
//  ContentView.swift
//  DocumentScanner
//
//  Created by Vishal Vaghasiya on 03/06/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var router = AppRouter()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Dashboard
            NavigationStack(path: $router.dashboardPath) {
                DashboardView(selectedTab: $selectedTab)
                    .navigationTitle(Strings.Dashboard.title)
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        router.destination(for: route)
                    }
            }
            .environmentObject(router)
            .tabItem {
                Label("Dashboard", systemImage: Images.System.dashboardTab)
            }
            .tag(0)
            
            // Tab 2: Files
            NavigationStack {
                FileManagerView()
            }
            .tabItem {
                Label("Files", systemImage: Images.System.filesTab)
            }
            .tag(1)
            
            // Tab 3: Settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: Images.System.settingsTab)
            }
            .tag(2)
        }
        .accentColor(.appPrimary)
    }
}

#Preview {
    ContentView()
}
