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
    @State private var goToNotes = false
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
            VStack {
                if auth.user == nil {
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
                    Text("Welcome To LeagueHelper! Please Sign In To Get Started")
                } else {
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
                        EnterRiotID(playerEmail: userEmail, goToNotes: $goToNotes)
                        Spacer()
                        GoalList()
                        Spacer()
                        MatchList()
                        NavigationLink(
                            destination: NoteView(goToNotes: $goToNotes),
                            isActive: $goToNotes
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
