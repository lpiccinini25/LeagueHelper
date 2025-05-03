//
//  Match.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 3/9/25.
//

import Foundation
import SwiftUI

struct Match: Hashable, Codable, Identifiable {
    var id: Int
    var assists: Int
    var kills: Int
    var deaths: Int
    var win: Bool
    var role: String
    var champion: String
}
