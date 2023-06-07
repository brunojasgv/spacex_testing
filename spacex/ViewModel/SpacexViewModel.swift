//
//  SpacexViewModel.swift
//  spacex
//
//  Created by Bruno Vasconcelos on 13/05/2023.
//
import Foundation
import Combine

enum FetchingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

enum LaunchFilter {
    case successful
    case failed
    case ascending
    case descending
}

final class GenericSession: GenericSessionProtocol {
    var session: URLSession {
        return URLSession.shared
    }
}

class SpaceXViewModel: ObservableObject {
    private let service: SpaceXServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var filter: LaunchFilter = .ascending
    
    @Published var launchesState: FetchingState<[LaunchModel]> = .idle
    @Published var infoState: FetchingState<CompanyModel> = .idle
    
    init(service: SpaceXServiceProtocol) {
        self.service = service
    }
    
    var filteredLaunches: [LaunchModel] {
        switch launchesState {
        case .loaded(let launches):
            switch filter {
            case .successful:
                return launches.filter { $0.success == true }
            case .failed:
                return launches.filter { $0.success == false }
            case .ascending:
                return launches.sorted { $0.date_utc?.compare($1.date_utc ?? Date()) == .orderedAscending }
            case .descending:
                return launches.sorted { $0.date_utc?.compare($1.date_utc ?? Date()) == .orderedDescending }
            }
        default:
            return []
        }
    }

    func applyFilter(_ filter: LaunchFilter) {
        self.filter = filter
    }

    func fetchLaunches() {
        launchesState = .loading
        service.fetchLaunches()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.launchesState = .error(error)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] launches in
                self?.launchesState = .loaded(launches)
            })
            .store(in: &cancellables)
    }
    
    func fetchInfo() {
        infoState = .loading
        service.fetchInfo()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.infoState = .error(error)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] info in
                self?.infoState = .loaded(info)
            })
            .store(in: &cancellables)
    }
}

