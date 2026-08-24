//
//  ProfileView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 19/06/25.
//

import SwiftUI

struct ProfileView: View {
    @State var title : String = "Profile"
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: false)
            Spacer()
            Text("User Profile")
            Spacer()
        }.navigationBarHidden(true) // Hide on this screen
    }
}

#Preview {
    ProfileView()
}
