//
//  LoginServiceProtocol.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import Foundation

protocol LoginServiceProtocol {
    func login(
        username: String,
        password: String,
        completion: @escaping (Result<LoginResponse, Error>) -> Void
    )
}
