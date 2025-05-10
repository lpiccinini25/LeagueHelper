//
//  MatchList.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 3/9/25.
//

import SwiftUI

// MARK: - API Key
let apiKey = "RGAPI-37057a3d-109c-45f0-b0fd-1cbaf8e4654a"

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

func fetchChampionIcon(from urlString: String,
                      completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data,
              let image = UIImage(data: data),
              error == nil
        else {
            completion(nil)
            return
        }
        DispatchQueue.main.async {
            completion(image)
        }
    }.resume()
}


// MARK: - ContentView
struct MatchList: View {
    @EnvironmentObject var userService: LeagueHelperUserInfo
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var reloadController: ReloadController
    @EnvironmentObject var goalService: LeagueHelperGoal
    
    @Binding var match: Match
    @Binding var viewMatchDetail: Bool
    
    @State private var puuid: String = "Fetching..."
    @State private var usernametagline: String = ""
    @State private var username: String = ""
    @State private var tagline: String = ""
    @State private var MatchIDs: [String] = []
    @State private var MatchList: [Match] = []
    @State private var showAlert: Bool = false
    @State private var champIcon: UIImage? = nil
    @State private var logoOpacity: Double = 0.0
    @State private var userInfo = UserInfo(
      playerEmail: "",
      riotID:     "",
      PUUID:      "",
      notes:      []
    )
    @State private var goals: [Goal] = []
    @State private var progress: String = "Fetching Matches..."
    
    private var playerEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    private func fetchUserInfo() async throws {
        do {
            userInfo = try await userService.fetchUserInfo(userEmail: playerEmail)
            print(userInfo.PUUID)
        } catch {
            print("Failed to update userInfo:", error)
        }
    }
    
    var body: some View {
            VStack {
                ScrollView {
                    Text(progress)
                    ForEach(MatchList) { game in
                        Button {
                            match = game
                            viewMatchDetail = true
                        } label: {
                            MatchRow(match: game)
                        }
                    }
                }
            }
            .task {
                // this runs once when the view appears
                do {
                    try await fetchUserInfo()
                    await fetchMatches()
                    await fetchMatchInfo(matches: MatchIDs)
                    try await goalService.updateGoalsQuantitative(userEmail: playerEmail, MatchList: MatchList)
                    
                } catch {
                    print("Failed to fetch UserInfo:", error)
                }
                
            }
            .onChange(of: reloadController.shouldReload) {
                Task {
                    do {
                        try await goalService.updateGoalsQuantitative(userEmail: playerEmail, MatchList: MatchList)
                    } catch {
                        print("Failed to fetch UserInfo:", error)
                    }
                }
            }
        }
    
    
    // MARK: - Helper Method
    
    private func fetchMatches() async {
        do {
            let matchesResult = try await fetchMATCHES(puuid: userInfo.PUUID)
            MatchIDs = matchesResult
        } catch {
            MatchIDs = []
        }
    }
    
    private func fetchMatchInfo(matches: [String]) async {
        let delayNS: UInt64 = 1_200_000_000  // 1.2s in nanoseconds
        MatchList = []
        progress = "Fetching Matches..."
        
        for (index, matchID) in matches.enumerated() {
            // after the very first request, pause to respect rate limit
            if index > 0 {
                try? await Task.sleep(nanoseconds: delayNS)
            }
            
            do {
                let GameInfo = try await fetchMATCHINFO(matchID: matchID)
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
                
                let ThisMatch = Match(matchID: matchID, id: index, assists: assists, kills: kills, deaths: deaths, win: win, role: role, champion: champion)
                await MainActor.run {
                    MatchList.append(ThisMatch)
                    reloadController.shouldReload.toggle()
                }
            } catch {
                print("Failed to fetch \(matchID): \(error)")
            }
        }
        progress = "All Matches Fetched!"
    }
}
