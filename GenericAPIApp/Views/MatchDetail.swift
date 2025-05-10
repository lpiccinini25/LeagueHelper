//
//  MatchDetail.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/7/25.
//

import SwiftUI
import UIKit

struct MatchDetail: View {
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var noteService: LeagueHelperNote
    @EnvironmentObject var auth: LeagueHelperAuth
    
    @State private var champIcon: UIImage? = nil
    @State var fetching = false
    @State var goals: [Goal]
    @State var match: Match
    
    private var playerEmail: String {
        auth.user?.email ?? "Unknown user"
    }

    
    private var backgroundColor: Color {
            match.win ? .pistachio : .roseMist
        }

    var body: some View {
        
        VStack {
            ScrollView {
                if let champIcon = champIcon {
                    CircleImage(Icon: champIcon, width: 200, height: 200)
                    
                } else {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
                
                GoalListMatchDetail(match: match)
                NoteEntry(match: match)
                NoteListMatchDetail(matchID: match.matchID)
            }
            .onAppear {
                let urlString = "https://ddragon.leagueoflegends.com/cdn/14.24.1/img/champion/\(match.champion).png"
                fetchChampionIcon(from: urlString) { image in
                  DispatchQueue.main.async {
                    self.champIcon = image
                  }
                }
            }
            .padding()
        }
        .background(Color(backgroundColor))
    }
}

