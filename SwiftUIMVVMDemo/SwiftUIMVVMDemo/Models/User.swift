//
//  User.swift
//  SwiftUIMVVMDemo
//
//  Created by Vishal Vaghasiya on 22/01/26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
}
