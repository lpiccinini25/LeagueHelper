//
//  UserInfo.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/5/25.
//

import Foundation
import SwiftUI

struct UserInfo: Hashable, Codable {
    var playerEmail: String
    var riotID: String
    var PUUID: String
    var notes: [String]
}
