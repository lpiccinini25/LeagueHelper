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

// MARK: - API Key
let apiKey = "RGAPI-6c1c7cd6-8b66-4572-a6c7-b60a03e5e90d"

// MARK: - Match Info

struct BaseDict: Codable {
    let metadata: MetaData
    let info: Info
}

struct MetaData: Codable {
    let participants: [String]
}

struct Info: Codable {
    let participants: [Participant]
}

struct Participant: Codable {
    let assists: Int
    let deaths: Int
    let kills: Int
    let win: Bool
    let championName: String
    let baronKills: Int
}

// MARK: - Async Fetch Function
func fetchPUUID(username: String, tagline: String) async throws -> String {
    let baseURL = "https://americas.api.riotgames.com"
    guard let url = URL(string: "\(baseURL)/riot/account/v1/accounts/by-riot-id/\(username)/\(tagline)?api_key=\(apiKey)") else {
        throw URLError(.badURL)
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    let decoded = try JSONDecoder().decode(RiotAccount.self, from: data)
    return decoded.puuid
}

func fetchMATCHES(puuid: String) async throws ->
    [String] {
        let baseURL = "https://americas.api.riotgames.com"
        guard let url = URL(string: "\(baseURL)/lol/match/v5/matches/by-puuid/\(puuid)/ids?state=0&count=30&api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let matchIDs = try JSONDecoder().decode([String].self, from: data)
        return matchIDs
}

func fetchMATCHINFO(matchID: String) async throws -> BaseDict {
    let baseURL = "https://americas.api.riotgames.com"
    guard let url = URL(string: "\(baseURL)/lol/match/v5/matches/\(matchID)?api_key=\(apiKey)") else {
        throw URLError(.badURL)
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    let GameINFO = try JSONDecoder().decode(BaseDict.self, from: data)
    return GameINFO
}

// MARK: - ContentView
struct MatchList: View {
    
    @State private var puuid: String = "Fetching..."
    @State private var usernametagline: String = ""
    @State private var username: String = ""
    @State private var tagline: String = ""
    @State private var Matches: [String] = []
    @State private var PlayerMatches: [Match] = []
    @State private var showAlert: Bool = false
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        VStack {
            Image("lol_logo") // Elias Segura: Logo Implementation
                .resizable()
                .position(x: 75, y: 40)
                .frame(width: 150, height: 80)
                .opacity(logoOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 2)){
                        logoOpacity = 1
                    }
                }
        
            
            TextField(
                "Enter username#tagline (Example: llimeincoconut#0000)",
                text: $usernametagline
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .position(x: 200, y: 10)
            .frame(width: 403, height: 28)

            let parts = usernametagline.components(separatedBy: "#")
            
            Button(action: { // Elias Segura: Button Implementation
                guard parts.count == 2 else {
                    showAlert = true
                    return
                }
                username = parts[0]
                tagline = parts[1]
                Task {
                    await fetchPuuid()
                    await fetchMatches()
                    await fetchMatchInfo(Matches: Matches)
                }
            }) {
                Text("Search")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 405, height: 60)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.gray.darkened(by: 0.4), .green.darkened(by: 0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomLeading
                        )
                        .cornerRadius(10)
                        .ignoresSafeArea(edges: .top)
                    )
            }
            .position(x: 200, y: 30)
            .frame(width: 400, height: 60)
            .alert(isPresented: $showAlert) { // Elias Segura
                Alert(
                    title: Text("Invalid Input"),
                    message: Text("Please enter a valid username#tagline."),
                    dismissButton: .default(Text("OK"))
                    )}
            .onSubmit {
                guard parts.count == 2 else {
                    showAlert = true
                    return
                }
                username = parts[0]
                tagline = parts[1]
                Task {
                    await fetchPuuid()
                    
                    await fetchMatches()
                    
                    await fetchMatchInfo(Matches: Matches)
                }
            }
            MatchList(MatchList: PlayerMatches)
            
            }
        
        .background( // Elias Segura: Backgound Graphics
            LinearGradient(
                gradient: Gradient(colors: [.green.opacity(0.2), .cyan.opacity(0.4)]),
                startPoint: .topTrailing,
                endPoint: .bottomTrailing
            )
        )
        
        
        }
    
    
    // MARK: - Helper Method
    private func fetchPuuid() async {
        do {
            let puuidResult = try await fetchPUUID(username: username, tagline: tagline)
            puuid = puuidResult
        } catch {
            puuid = "Error fetching PUUID"
        }
    }
    
    private func fetchMatches() async {
        do {
            let matchesResult = try await fetchMATCHES(puuid: puuid)
            Matches = matchesResult
        } catch {
            Matches = []
        }
    }
    
    private func fetchMatchInfo(Matches: [String]) async {
        PlayerMatches = []
        var game = 0
        for match in Matches {
            do {
                let GameInfo = try await fetchMATCHINFO(matchID: match)
                var i = 0
                var playerIndex = 0
                while i < 10 {
                    if (GameInfo.metadata.participants[i] == puuid) {
                        playerIndex = i
                    }
                    i += 1
                }
                
                var role = "lll"
                if (playerIndex%5 == 0)  {
                    role = "Top"
                } else if (playerIndex%5 == 1) {
                    role = "Jungle"
                } else if (playerIndex%5 == 2) {
                    role = "Mid"
                } else if (playerIndex%5 == 3) {
                    role = "ADC"
                } else {
                    role = "Support"
                }
                
                let playerStats = GameInfo.info.participants[playerIndex]
                let assists = playerStats.assists
                let kills = playerStats.kills
                let deaths = playerStats.deaths
                let win = playerStats.win
                let champion = playerStats.championName
                
                let ThisMatch = Match(id: game, assists: assists, kills: kills, deaths: deaths, win: win, role: role, champion: champion)
                game += 1
                await MainActor.run {
                    PlayerMatches.append(ThisMatch)
                }
            } catch {
                
            }
        }
    }
}
