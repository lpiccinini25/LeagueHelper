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
    
    @Binding var goToEnterRiotID: Bool
    
    private func updateRiotID () async {
        do {
            try await userService.updateRiotId(playerEmail: playerEmail, riotID: riotID)
        } catch {
            print("Failed to update Riot ID:", error)
        }
        
    }
    
    
    var body: some View {
        TextField(
            "Enter username#tagline (Example: llimeincoconut#0000)",
            text: $riotID
        )
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("Submit") {
                    Task {
                        await updateRiotID()
                    }
                    goToEnterRiotID = false
                    reloadController.shouldReload.toggle()
                }
            }
        }
    }
}
