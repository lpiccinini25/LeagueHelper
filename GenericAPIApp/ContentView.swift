//
//  ContentView.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 2/11/25.
//
// CHUNGUS CHUNGUS

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @State var requestLogin = false
    
    var body: some View {
        if let authUI = auth.authUI {
            Home(requestLogin: $requestLogin)
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
