//
//  ContentView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 29/03/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State var title: String = "Welcome to SwiftUI"
    @State private var size: CGFloat = 2.0
    @State var email: String = ""
    @State var password: String = ""
    let imageUrl = URL(string: "https://tinyurl.com/2nwsh3fd")!
    @State private var isLogin = false
    var body: some View {
        NavigationStack {
            //        ZStack {
            //            Image("wallpaper")
            //                .resizable()
            //                .scaledToFill()
            //                .edgesIgnoringSafeArea(.all)
            //                .blur(radius: 8)
            VStack {
                //            Text("Login")
                //                .frame(maxWidth: .infinity, maxHeight: 44).foregroundColor(.white)
                //                .font(.system(size: 17, weight: .semibold))
                
                //            Image(systemName: "person.crop.circle")
                //                .resizable()
                //                .frame(width: 100, height: 100)
                //                .foregroundColor(.white)
                //                .clipShape(Circle())
                
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Show loading indicator
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "person.crop.circle").resizable()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .foregroundColor(.white)
                .shadow(radius: 8)
                
                Text("CARE COORDINATION")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(0.5)
                Text("Post-Acute Care Coordinations Simplified!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                
                ScrollView {
                    Text("WELCOME TO CARE COORDINATIONS")
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .tracking(0.5)
                    
                    Text("Login into your account")
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .tracking(0.5)
                    
                    VStack (spacing: 15) {
                        TextField("Email", text: $email)
                            .padding()
                            .frame(height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            .onTapGesture {
                                
                            }
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .frame(height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
                            .onTapGesture {
                                
                            }
                            .onChange(of: password) { newValue in
                                print(newValue)
                            }
                        
                    }.padding(.leading, 15).padding(.trailing, 15)
                    
                    Button {
                        isLogin = true
                    } label: {
                        Text("Login")
                            .frame(width: 280, height: 50)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .background(.theme)
                            .cornerRadius(8)
                    }.padding(.top, 30)
                        .shadow(radius: 2)
                    
                    Text("Don't have an account? **Sign up**") .onTapGesture {
                        print("Move to signup")
                    }
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                    .underline()
                    
                    //                VStack(alignment: .center, spacing: 10) {
                    ////                    titleView(text: title, completion: { value in
                    ////                        print(title)
                    ////                    })
                    //
                    ////                    RoundedRectangle(cornerRadius: 1).frame(maxWidth: .infinity, maxHeight: 2).foregroundColor(.gray)
                    //
                    ////                    buttonView { }
                    //
                    //                }.padding(.leading, 20).padding(.trailing, 20)
                    Spacer()
                }/*.safeAreaPadding(.top)*/
                .background(Color.white)
            }.background(.theme)
                .navigationDestination(isPresented: $isLogin) {
                    DashboardView()
                }
        }
    }
    
    //    }
}

struct textStyle: ViewModifier {
    func body(content: Content) -> some View  {
        content
            .frame(maxWidth: .infinity).padding(8)
            .font(.system(size: 30))
            .bold()
            .foregroundStyle(Color("Red"))
            .background(Color.yellow)
            .cornerRadius(8)
            .shadow(radius: 5)
            .strikethrough(true)
            .lineSpacing(5)
            .tracking(2)
            .multilineTextAlignment(.center)
    }
}

struct buttonStyle: ViewModifier {
    func body(content: Content) -> some View  {
        content
            .frame(maxWidth: .infinity).padding(8)
            .font(.system(size: 30))
            .bold()
            .foregroundStyle(Color("Red"))
            .background(Color.yellow)
            .cornerRadius(8)
            .shadow(radius: 5)
            .strikethrough(true)
            .lineSpacing(5)
            .tracking(2)
            .multilineTextAlignment(.center)
    }
}

func titleView(text: String, completion: @escaping ((String) -> Void)) -> some View  {
    return Text(text).modifier(textStyle())
        .onTapGesture {
            completion("How are you?")
        }
}

func buttonView(completion: @escaping (() -> Void))  -> some View {
    
    HStack (alignment: .center, spacing: 20) {
        Button {
            print("Clicked")
        } label: {
            Text("Cancel")
                .frame(width: 120, height: 40)
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red, lineWidth: 1)
                )
        }
        
        Button {
            print("Clicked")
        } label: {
            Text("Login")
                .frame(width: 150, height: 40)
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }.padding(.leading, 20).padding(.trailing, 20)
}

#Preview {
    LoginView()
}
