//
//  ListView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 12/04/25.
//

import SwiftUI

struct ListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var arrOfList = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    @State var title : String = "List View"
    
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: true) {
                dismiss()
            }
            ZStack {
                VStack {
                    List (arrOfList, id: \.self)  { item in
                        Text(item)
                    }.listStyle(SidebarListStyle())
                        .padding(.top, -10) // Shift form upward to remove 10pt gap
                }
            }
        }.navigationBarHidden(true) // Hide on this screen
    }
}

#Preview {
    ListView()
}
