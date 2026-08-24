//
//  LoginService.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import Foundation


final class LoginService: LoginServiceProtocol {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func login(
        username: String,
        password: String,
        completion: @escaping (Result<LoginResponse, Error>) -> Void
    ) {
        let request = URLRequest(url: URL(string: "https://api.test.com/login")!)
        apiClient.request(request, completion: completion)
    }
}
