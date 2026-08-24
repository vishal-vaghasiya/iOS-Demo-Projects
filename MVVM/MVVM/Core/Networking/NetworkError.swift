//
//  NetworkError.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

enum NetworkError: Error {
    case noData
    case invalidURL
    case noInternet
    case serverError
    case decodingFailed
}
