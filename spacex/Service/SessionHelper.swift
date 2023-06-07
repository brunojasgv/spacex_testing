//
//  SessionHelper.swift
//  spacex
//
//  Created by Bruno Vasconcelos on 12/05/2023.
//

import Foundation
import Combine

enum NetworkError: Error {
    case badHTTPResponse
    case unknown
    var localizedDescription: String {
        switch self {
        case .badHTTPResponse:
            return "Received a non-200 HTTP response"
        case .unknown:
            return "An unknown error has occurred"
        }
    }
}

protocol GenericSessionProtocol {
    var session: URLSession { get }
    func execute<T>(_ request: URLRequest, decodingType: T.Type, queue: DispatchQueue, retries: Int) -> AnyPublisher<T, Error> where T: Decodable
}

extension GenericSessionProtocol {
    
    func execute<T>(_ request: URLRequest,
                    decodingType: T.Type,
                    queue: DispatchQueue = .main,
                    retries: Int = 0) -> AnyPublisher<T, Error> where T: Decodable {
        
        return session.dataTaskPublisher(for: request)
            .tryMap {
                guard let response = $0.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.badHTTPResponse
                }
                return $0.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: queue)
            .retry(retries)
            .eraseToAnyPublisher()
    }
}

protocol Endpoint {
    
    var base: String { get }
    var path: String { get }
}
extension Endpoint {
    
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url!
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
}
