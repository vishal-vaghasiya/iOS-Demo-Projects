//
//  APICallingView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 19/06/25.
//

import SwiftUI

struct APICallingView: View {
    @State var title : String = "Get Post API"
    
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: true)
            Spacer()
            VStack(alignment: .center) {
                Button {
                    APIManager.shared.fetchData(forAPI: "getCountries", withParameter: "", isAuthenticated: false) { result in
                        switch result {
                        case .success(let response):
                            print("GET Success: \(response)")
                        case .failure(let error):
                            print("GET Error: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Text("GET")
                    .frame(width: 280, height: 50)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .background(.theme)
                    .cornerRadius(8)
                }.padding(.top, 30)
                    .shadow(radius: 2)
                
                Button {
                    let parameters = ["email": "vishal.systemadmin@yopmail.com",
                                 "password": "Vishal@123456",
                                 "fcm_id": "",
                                 "device_id": UIDevice.current.identifierForVendor!.uuidString,
                                 "voip_push_token": "",
                                 "activity_token": "",
                                 "device_type": 3] as [String : Any]
                    
                    APIManager.shared.postData(forAPI: "userSignIn", withParameters: parameters, isAuthenticated: false) { result in
                        switch result {
                        case .success(let response):
                            print("POST Success: \(response)")
                        case .failure(let error):
                            print("POST Error: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Text("POST")
                    .frame(width: 280, height: 50)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .background(.theme)
                    .cornerRadius(8)
                }.padding(.top, 30)
                    .shadow(radius: 2)
            }
            
            Spacer()
        }
    }
}

//#Preview {
//    APICallingView()
//}
