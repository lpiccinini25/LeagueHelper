//
//  Goal.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/3/25.
//

struct Goal: Hashable, Codable, Identifiable {
    var id: String
    var title: String
    var quantitative: Bool
    var quantity: Int
    var playerEmail: String
    var successes: [String]
    var fails: [String]
}
