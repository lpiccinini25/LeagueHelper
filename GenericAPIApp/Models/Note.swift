//
//  Note.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//

import Foundation
import SwiftUI

struct Note: Hashable, Codable, Identifiable {
    var matchID: String
    var id: String
    var playerEmail: String
    var content: String
    var assists: Int
    var kills: Int
    var deaths: Int
    var win: Bool
    var role: String
    var champion: String
}
