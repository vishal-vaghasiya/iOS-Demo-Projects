//
//  FormView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 12/04/25.
//

import SwiftUI

struct FormView: View {
    @State var title : String = "Form View"
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: true) {
                dismiss()
            }
            VStack {
                Form {
                    HStack {
                        Spacer()
                        Text("Login")
                            .foregroundStyle(.theme)
                            .font(.system(size: 20))
                            .bold(true)
                        Spacer()
                    }.listRowSeparator(.hidden)
                    TextField("Enter your email", text: .constant(""))
                    SecureField("Enter your passwrod", text: .constant(""))
                    
                    Button {
                        
                    } label: {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .background(.theme)
                            .cornerRadius(8)
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 15)
                    .shadow(radius: 2)
                }
                //.listStyle(.plain)
                //.scrollContentBackground(.hidden)
                //.background(.theme)
                .padding(.top, -10) // Shift form upward to remove 10pt gap
            }
        }
        .navigationBarHidden(true) // Hide on this screen
    }
}

#Preview {
    FormView()
}
