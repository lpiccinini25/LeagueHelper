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
    @EnvironmentObject var noteService: LeagueHelperNote
    
    @Binding var requestLogin: Bool
    
    @State private var goals: [Goal] = []
    @State private var error: Error?
    @State private var fetching = false
    @State private var writing = false
    
    @State private var match: Match = Match(
        matchID: "",
        id: 0,
        assists: 0,
        kills: 0,
        deaths: 0,
        win: false,
        role: "",
        champion: ""
    )
    @State private var viewMatchDetail: Bool = false
    
    @State private var changeAccount = false
    @State private var goToNotes = false
    @State private var goToEnterRiotID = false
    
    @State private var activeSheet: ActiveSheet?
    @State private var logoOpacity: Double = 0.0
    
    
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
            VStack(spacing: 12) {
                if auth.user == nil {
                    Image("lol_logo")
                        .resizable()
                        .position(x: 75, y: 40)
                        .frame(width: 150, height: 80)
                        .opacity(logoOpacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 2)){
                                logoOpacity = 1
                            }
                        }
                    Text("Welcome To LeagueHelper! Please Sign In To Get Started")
                } else {
                    VStack {
                        Image("lol_logo")
                            .resizable()
                            .position(x: 75, y: 40)
                            .frame(width: 150, height: 80)
                            .opacity(logoOpacity)
                            .onAppear {
                                withAnimation(.easeIn(duration: 2)){
                                    logoOpacity = 1
                                }
                            }
                        GoalListHome()
                        MatchList(match: $match, viewMatchDetail: $viewMatchDetail)
                        NavigationLink(
                            destination: NoteView(goToNotes: $goToNotes),
                            isActive: $goToNotes
                        ) {
                            EmptyView()
                        }
                        .hidden()
                        NavigationLink(
                            destination: EnterRiotID(playerEmail: userEmail, goToEnterRiotID: $goToEnterRiotID),
                            isActive: $goToEnterRiotID
                        ) {
                            EmptyView()
                        }
                        .hidden()
                        NavigationLink(
                            destination: GoalEntry(goals: $goals, writing: $writing),
                            isActive: $writing
                        ) {
                            EmptyView()
                        }
                        .hidden()

                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if auth.user != nil {
                        Button("New Goal") {
                            writing = true
                        }
                        Button("View Notes") {
                            goToNotes = true
                        }
                        Button("Enter RiotID") {
                            goToEnterRiotID = true
                        }
                    }
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
            .sheet(isPresented: $viewMatchDetail) {
                MatchDetail(viewMatchDetail: $viewMatchDetail, match: match)
            }
        }
        .onChange(of: auth.user) {
            guard auth.user != nil else { return }
          Task {
            try await tryCreateUser()
          }
        }
    }
}
