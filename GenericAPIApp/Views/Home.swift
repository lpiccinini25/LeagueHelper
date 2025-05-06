//
//  Home.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/3/25.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var reloadController: ReloadController
    @EnvironmentObject var userService: LeagueHelperUserInfo
    
    @Binding var requestLogin: Bool
    
    @State private var goals: [Goal] = []
    @State private var error: Error?
    @State private var fetching = false
    @State private var writing = false
    @State private var changeAccount = false
    @State private var activeSheet: ActiveSheet?
    
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    enum ActiveSheet: Identifiable {
        case goalEntry, changeAccount
        
        var id: Int {
            hashValue
        }
    }
    
    func tryCreateUser() async throws {
        let newUser = UserInfo(
            playerEmail: userEmail,
            riotID: "",
            PUUID: "",
            notes: []
        )
        print("try create")
        try await userService.createUser(playerEmail: userEmail, userInfo: newUser)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if auth.user == nil {
                    Text("Welcome To LeagueHelper! Please Sign In To Get Started")
                } else {
                    EnterRiotID(playerEmail: userEmail)
                    GoalList()
                    MatchList()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if auth.user != nil {
                        Button("New Goal") {
                            writing = true
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if auth.user != nil {
                        Button("Sign Out") {
                            do {
                                try auth.signOut()
                            } catch {
                                // No error handling in the sample, but of course there should be
                                // in a production app.
                            }
                        }
                    } else {
                        Button("Sign In") {
                            requestLogin = true
                        }
                    }
                }
            }
        }
        .onChange(of: auth.user) {
            guard auth.user != nil else { return }
          Task {
            try await tryCreateUser()
          }
        }
        .sheet(isPresented: $writing) {
            GoalEntry(goals: $goals, writing: $writing)
        }
    }
}
