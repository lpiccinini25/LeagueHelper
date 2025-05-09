//
//  EnterRiotID.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/6/25.
//

import SwiftUI
import FirebaseAuth


struct EnterRiotID: View {
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var reloadController: ReloadController
    @EnvironmentObject var userService: LeagueHelperUserInfo
    
    let playerEmail: String
    @State private var riotID: String = ""
    @State private var PUUID: String = ""
    @State private var notes: [String] = []
    
    @Binding var goToNotes: Bool
    
    private func updateRiotID () async {
        do {
            try await userService.updateRiotId(playerEmail: playerEmail, riotID: riotID)
        } catch {
            print("Failed to update Riot ID:", error)
        }
        
    }
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                TextField(
                    "Enter username#tagline (Example: llimeincoconut#0000)",
                    text: $riotID
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .position(x: 200, y: 10)
                .frame(width: 403, height: 28)
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("View Notes") {
                            goToNotes = true
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Submit") {
                            Task {
                                await updateRiotID()
                            }
                            reloadController.shouldReload.toggle()
                        }
                    }
                }
            }
        }
    }
}
