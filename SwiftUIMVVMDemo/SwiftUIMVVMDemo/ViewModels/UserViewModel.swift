//
//  UserViewModel.swift
//  SwiftUIMVVMDemo
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import SwiftUI
import Combine

final class UserViewModel: ObservableObject {

    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchUsers() {
        isLoading = true
        errorMessage = nil

        APIService.shared.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
