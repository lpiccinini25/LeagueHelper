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
    
    @State var goals: [Goal] = []
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    @State var changeAccount = false
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }

    var body: some View {
        NavigationView {
            VStack {
                if auth.user == nil {
                    Text("Welcome To LeagueHelper! Please Sign In To Get Started")
                } else {
                    Button("Enter/Change Account") {
                        
                    }
                    GoalList()
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
        .sheet(isPresented: $writing) {
            GoalEntry(goals: $goals, writing: $writing)
        .sheet(isPresented: $writing) {
            GoalEntry(goals: $goals, writing: $writing)
        }
        }
    }
}

