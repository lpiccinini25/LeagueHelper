//
//  MatchRow.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 3/9/25.
//

import SwiftUI

extension Color {
    // Light Greens
    static let mintLight    = Color(red: 223/255, green: 243/255, blue: 227/255) // #DFF3E3
    static let sageLight    = Color(red: 200/255, green: 230/255, blue: 201/255) // #C8E6C9
    static let pistachio    = Color(red: 232/255, green: 245/255, blue: 233/255) // #E8F5E9

    // Light Reds / Pinks
    static let blushLight   = Color(red: 255/255, green: 205/255, blue: 210/255) // #FFCDD2
    static let coralLight   = Color(red: 239/255, green: 154/255, blue: 154/255) // #EF9A9A
    static let roseMist     = Color(red: 255/255, green: 235/255, blue: 238/255) // #FFEBEE
}

struct MatchRow: View {
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var auth: LeagueHelperAuth
    var match: Match
    
    @State private var champIcon: UIImage? = nil
    @State private var completed: Bool = false
    
    private var playerEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    private var backgroundColor: Color {
            match.win ? .pistachio : .roseMist
        }
    
    func checkIfGoalsCompleted(playerEmail: String, matchID: String) async throws -> Bool {
        let goals = try await goalService.fetchGoals(userEmail: playerEmail)
        var contains = true
        for goal in goals {
            if goal.successes.contains(matchID) || goal.fails.contains(matchID) {

            } else {
                contains = false
            }
        }
        return contains
    }
    
    var body: some View {
        HStack(spacing: 8) {
            VStack {
                HStack {
                    Text("Playing " + match.role + " as " + match.champion)
                        .font(.headline)
                        .foregroundColor(.black)
                        .bold()
                    
                    Spacer()
                    
                    StatusBadge(completed: completed)
                }
                
                HStack {
                    if match.win {
                        Text("Win")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                    } else {
                        Text("Loss")
                            .font(.headline)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                
                HStack {
                    Label("Assists", systemImage: "hands.sparkles")
                    Spacer()
                    Text(String(match.assists))
                        .bold()
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
            VStack {
                if let champIcon = champIcon {
                    CircleImage(Icon: champIcon, width: 100, height: 100)
                }
            }
            
        }
        .onAppear {
            let urlString = "https://ddragon.leagueoflegends.com/cdn/14.24.1/img/champion/\(match.champion).png"
            fetchChampionIcon(from: urlString) { image in
                champIcon = image
            }
        }
        .task {
            do {
                completed = try await checkIfGoalsCompleted(playerEmail: playerEmail, matchID: match.matchID)
            } catch {
                print("error")
            }
        }
        .padding()
        .background(Color(backgroundColor))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let completed: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(completed ? "Reviewed!" : "Unreviewed!")
            
            Spacer()
            
            Image(systemName: completed
                  ? "checkmark.circle.fill"
                  : "exclamationmark.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(completed ? .green : .yellow)
        }
    }
}
