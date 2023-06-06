//
//  CompanyModel.swift
//  spacex
//
//  Created by Bruno Vasconcelos on 12/05/2023.
//

import Foundation

struct CompanyModel: Codable {
    let name: String?
    let founder: String?
    let founded : Int?
    let employees: Int?
    let launchSites: Int?
    let valuation: Int?
    
    init(name: String?, founder: String?, founded: Int?, employees: Int?, launchSites: Int?, valuation: Int?) {
        self.name = name
        self.founder = founder
        self.founded = founded
        self.employees = employees
        self.launchSites = launchSites
        self.valuation = valuation
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        founder = try values.decodeIfPresent(String.self, forKey: .founder)
        founded = try values.decodeIfPresent(Int.self, forKey: .founded)
        employees = try values.decodeIfPresent(Int.self, forKey: .employees)
        launchSites = try values.decodeIfPresent(Int.self, forKey: .launchSites)
        valuation = try values.decodeIfPresent(Int.self, forKey: .valuation)
    }
}

