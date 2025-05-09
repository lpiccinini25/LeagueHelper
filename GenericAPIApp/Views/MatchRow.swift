//
//  MatchRow.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 3/9/25.
//

import SwiftUI

struct MatchRow: View {
    
    var match: Match
    
    @State private var champIcon: UIImage? = nil
    
    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(match.role + " as " + match.champion)
                    .font(.headline)
                    .foregroundColor(.black)
                    .bold()
                Spacer()
            }
            
            HStack {
                Text(String(match.id))
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
            
            HStack {
                Label("Assists", systemImage: "hands.sparkles")
                Spacer()
                Text(String(match.assists))
                    .bold()
                if let champIcon = champIcon {
                    CircleImage(Icon: champIcon)
                }
            }
            
            HStack {
                Label("Kills", systemImage: "crosshairs")
                Spacer()
                Text(String(match.kills))
                    .bold()
            }
            
            HStack {
                Label("Deaths", systemImage: "skull")
                Spacer()
                Text(String(match.deaths))
                    .bold()
            }
            
        }
        .onAppear {
            let urlString = "https://ddragon.leagueoflegends.com/cdn/14.24.1/img/champion/\(match.champion).png"
            fetchChampionIcon(from: urlString) { image in
                champIcon = image
            }
        }
        .padding()
        .background(match.win == true ? Color(.green) : Color(.red))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    }
}
