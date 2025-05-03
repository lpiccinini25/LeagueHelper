//
//  MatchList.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 3/9/25.
//

import SwiftUI

struct MatchList: View {
    
    var MatchList: [Match]
    
    var body: some View {
        
        ScrollView {
            ForEach(MatchList) { game in
                MatchRow(match: game)
            }
        }
    }
}
