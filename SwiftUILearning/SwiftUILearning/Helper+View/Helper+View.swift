//
//  Helper+View.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 12/04/25.
//

import SwiftUI

//MARK: HEADER VIEW FOR ALL SCREEN
struct HeaderView : View {
    var title : String
    var isBack : Bool
    var onBack : (() -> Void)?
    
    var body : some View {
        HStack {
            if isBack {
                Button(action: onBack ?? { }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }.bold()
                    .padding(.leading)
            }
            Text(title)
                .frame(maxWidth: .infinity, maxHeight: 44)
                .bold()
                .foregroundColor(.white)
                .padding(.trailing, isBack ? 38 : 0)
        }.frame(maxWidth: .infinity, maxHeight: 44, alignment: .center)
            .background(.theme)
    }
}

//#Preview {
//    HeaderView(title: "Hello", isBack: true)
//}
