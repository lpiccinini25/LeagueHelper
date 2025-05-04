//
//  Home.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/3/25.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @State var requestLogin = false

    var body: some View {
        if let authUI = auth.authUI {
            GoalList(requestLogin: $requestLogin, goals: [])
                .sheet(isPresented: $requestLogin) {
                    AuthenticationViewController(authUI: authUI)
                }
        } else {
            VStack {
                Text("Sorry, looks like we aren’t set up right!")
                    .padding()

                Text("Please contact this app’s developer for assistance.")
                    .padding()
            }
        }
    }
}
