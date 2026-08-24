//
//  APIClient.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(
        _ endpoint: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    )
}

final class APIClient: APIClientProtocol {

    func request<T: Decodable>(
        _ endpoint: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: endpoint) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(NetworkError.decodingFailed))
            }
        }.resume()
    }
}
