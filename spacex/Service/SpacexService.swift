//
//  SpacexService.swift
//  spacex
//
//  Created by Bruno Vasconcelos on 12/05/2023.
//

import Foundation
import Combine


/// SpaceXEndpoint is an enumeration that represents different API endpoints of the SpaceX API.
/// It conforms to the Endpoint protocol which ensures each endpoint provides a base URL and path.
enum SpaceXEndpoint: Endpoint {
    case launches
    case info

    var base: String {
        return "https://api.spacexdata.com"
    }
    
    var path: String {
        switch self {
        case .launches:
            return "/v4/launches"
        case .info:
            return "/v4/company"
        }
    }
}

/// SpaceXServiceProtocol is a protocol that defines the necessary services required from the SpaceX API.
/// This protocol ensures that any class that is used as a SpaceXService provides the necessary methods.
protocol SpaceXServiceProtocol {
    func fetchLaunches() -> AnyPublisher<[LaunchModel], Error>
    func fetchInfo() -> AnyPublisher<CompanyModel, Error>
}

/// SpaceXService is a class that fetches data from the SpaceX API.
/// It uses the GenericSession to send requests and conforms to the SpaceXServiceProtocol.
/// This class is an example of abstraction and decoupling as it separates the concerns of fetching SpaceX data from the rest of the app.
final class SpaceXService: SpaceXServiceProtocol {
    
    private let session: GenericSessionProtocol

    init(session: GenericSessionProtocol) {
        self.session = session
    }

    func fetchLaunches() -> AnyPublisher<[LaunchModel], Error> {
        let request = SpaceXEndpoint.launches.request
        return session.execute(request, decodingType: [LaunchModel].self, queue: .main)
            .eraseToAnyPublisher()
    }

    func fetchInfo() -> AnyPublisher<CompanyModel, Error> {
        let request = SpaceXEndpoint.info.request
        return session.execute(request, decodingType: CompanyModel.self, queue: .main)
    }
}




