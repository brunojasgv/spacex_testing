//
//  ViewController.swift
//  spacex
//
//  Created by Bruno Vasconcelos on 12/05/2023.
//

import UIKit
import Combine

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var viewModel: SpaceXViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        // - viewModel: The ViewModel in the MVVM architecture for the application.
        // It is being initialized with a SpaceXService, which in turn is initialized with a GenericSession.
        // This setup demonstrates dependency injection, which makes the code more modular, testable, and maintainable.
        // Each component can be modified or tested independently, and the SpaceXViewModel is not directly dependent on concrete classes for its dependencies.
        viewModel = SpaceXViewModel(service: SpaceXService(session: GenericSession()))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        viewModel.fetchLaunches()
        viewModel.fetchInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.$launchesState.sink { [weak self] state in
            self?.stateIndicator(state)
        }
        .store(in: &cancellables)
        
        viewModel.$infoState.sink { [weak self] state in
            if case .loaded(let info) = state {
                self?.labelInfo.text = "Company: \(info.name ?? ""), CEO: \(info.valuation ?? 0)"
            }
        }.store(in: &cancellables)
        
    }
    
    private func stateIndicator(_ state: FetchingState<[LaunchModel]>) {
        switch state {
        case .idle:
            print("idle")
        case .loading:
            print("loading")
        case .loaded(let launches):
            print("Loaded: \(launches.count)")
        case .error(let error):
            print("error: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredLaunches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchCell", for: indexPath)
        let launch = viewModel.filteredLaunches[indexPath.row]
        cell.textLabel?.text = launch.name
        cell.detailTextLabel?.text = launch.success ?? false ? "Success" : "Failed"
        return cell
    }
    
    func filterButtonTapped() {
        let alertController = UIAlertController(title: "Filter", message: "Select a filter", preferredStyle: .actionSheet)
        
        let successfulLaunchAction = UIAlertAction(title: "Successful Launches", style: .default) { _ in
            self.applyFilter(.successful)
        }
        alertController.addAction(successfulLaunchAction)
        
        let failedLaunchAction = UIAlertAction(title: "Failed Launches", style: .default) { _ in
            self.applyFilter(.failed)
        }
        alertController.addAction(failedLaunchAction)
        
        let ascendingAction = UIAlertAction(title: "Sort Ascending", style: .default) { _ in
            self.applyFilter(.ascending)
        }
        alertController.addAction(ascendingAction)
        
        let descendingAction = UIAlertAction(title: "Sort Descending", style: .default) { _ in
            self.applyFilter(.descending)
        }
        alertController.addAction(descendingAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func applyFilter(_ filter: LaunchFilter) {
        viewModel.applyFilter(filter)
        tableView.reloadData()
    }
    
    @IBAction func actionFilter(_ sender: Any) {
        self.filterButtonTapped()
    }
}


