//
//  spacexTests.swift
//  spacexTests
//
//  Created by Bruno Vasconcelos on 12/05/2023.
//

import Combine
import XCTest
@testable import spacex


final class SpaceXTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    var viewModel: SpaceXViewModel!
    
    
    /// - mockSession: Initialize a MockURLSession with the mockData.
    /// This MockURLSession is a fake URLSession that can be used to simulate network requests and responses.
    override func setUp() {
        super.setUp()
        
        guard let url = Bundle.main.url(forResource: "mock", withExtension: "json"),
              let mockData = try? Data(contentsOf: url) else {
            fatalError("Failed to load mock.json from bundle")
        }
        
        
        let mockSession = MockURLSession(mockData: mockData)
        
        let service = SpaceXService(session: mockSession)
        
        viewModel = SpaceXViewModel(service: service)
        
        let fetchLaunchesExpectation = XCTestExpectation(description: "Fetch launches for setup")
        viewModel.$launchesState
            .sink(receiveValue: { state in
                if case .loaded = state {
                    fetchLaunchesExpectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        // The expectation will be fulfilled in the sink when the launchesState is .loaded.
        viewModel.fetchLaunches()

        wait(for: [fetchLaunchesExpectation], timeout: 1.0)
    }
    
    func testFetchLaunchesSuccess() {
        let expectation = XCTestExpectation(description: "Fetch launches")
        viewModel.$launchesState
            .sink(receiveValue: { state in
                if case .loaded(let launches) = state {
                    XCTAssertEqual(launches.count, 205)
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        viewModel.fetchLaunches()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchInfoSuccess() {
        let expectation = XCTestExpectation(description: "Fetch info")
        viewModel.$infoState
            .sink(receiveValue: { state in
                if case .loaded(let info) = state {
                    XCTAssertEqual(info.name, "SpaceX")
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        viewModel.fetchInfo()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSuccessfulFilter() {
        viewModel.applyFilter(.successful)
        
        let filteredLaunches = viewModel.filteredLaunches
        //Check that all launches in filteredLaunches are successful
        for launch in filteredLaunches {
            XCTAssertTrue(launch.success == true)
        }
    }
    
    func testFailedFilter() {
        viewModel.applyFilter(.failed)
        
        let filteredLaunches = viewModel.filteredLaunches
        //Check that all launches in filteredLaunches are failed
        for launch in filteredLaunches {
            XCTAssertTrue(launch.success == false)
        }
    }
    
    func testAscendingFilter() {
        viewModel.applyFilter(.ascending)
        
        let filteredLaunches = viewModel.filteredLaunches
        //Check that all launches in filteredLaunches are in ascending order
        for i in 1..<filteredLaunches.count {
            XCTAssertTrue(filteredLaunches[i-1].date_utc ?? Date() <= filteredLaunches[i].date_utc ?? Date())
        }
    }
    
    func testDescendingFilter() {
        viewModel.applyFilter(.descending)
        
        let filteredLaunches = viewModel.filteredLaunches
        //Check that all launches in filteredLaunches are in descending order
        for i in 1..<filteredLaunches.count {
            XCTAssertTrue(filteredLaunches[i-1].date_utc ?? Date() >= filteredLaunches[i].date_utc ?? Date())
        }
    }
    
}


