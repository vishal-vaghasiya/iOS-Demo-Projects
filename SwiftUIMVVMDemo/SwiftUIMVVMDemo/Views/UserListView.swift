//
//  UserListView.swift
//  SwiftUIMVVMDemo
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import SwiftUI

struct UserListView: View {

    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    List(viewModel.users) { user in
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Users")
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
}

#Preview {
    UserListView()
}
