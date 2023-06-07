//
//  SpacexService.swift
//  spacex
//
//  Created by Bruno Vasconcelos on 12/05/2023.
//

import Foundation
import Combine


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

protocol SpaceXServiceProtocol {
    func fetchLaunches() -> AnyPublisher<[LaunchModel], Error>
    func fetchInfo() -> AnyPublisher<CompanyModel, Error>
}

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




