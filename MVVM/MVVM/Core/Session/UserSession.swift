//
//  UserSession.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

final class UserSession {

    static let shared = UserSession()

    private init() {}

    var token: String?
    var userId: Int?

    var isLoggedIn: Bool {
        token != nil
    }
}
