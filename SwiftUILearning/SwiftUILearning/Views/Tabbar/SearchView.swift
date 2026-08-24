//
//  SearchView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 19/06/25.
//

import SwiftUI

struct SearchView: View {
    @State var title : String = "Search"
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: false)
            Spacer()
            Text("Search Here")
            Spacer()
        }.navigationBarHidden(true) // Hide on this screen
    }
}

#Preview {
    SearchView()
}
