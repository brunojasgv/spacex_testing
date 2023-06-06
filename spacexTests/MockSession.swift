//
//  MockSession.swift
//  spacex
//
//  Created by Bruno Vasconcelos on 13/05/2023.
//

import Foundation
import Combine

struct MockURLSession: GenericSessionProtocol {
    var session: URLSession
    var mockData: Data

    init(mockData: Data) {
        self.session = URLSession.shared
        self.mockData = mockData
    }

    func execute<T>(_ request: URLRequest, decodingType: T.Type, queue: DispatchQueue = .main, retries: Int = 0) -> AnyPublisher<T, Error> where T : Decodable {
        return Future { promise in
            do {
                let decoded = try JSONDecoder().decode(T.self, from: self.mockData)
                promise(.success(decoded))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: queue)
        .eraseToAnyPublisher()
    }
}
