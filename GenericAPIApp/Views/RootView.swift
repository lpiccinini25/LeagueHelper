//
//  RootView.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/4/25.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @State private var isSignedIn = Auth.auth().currentUser != nil

    var body: some View {
        if isSignedIn {
            Home()
        } else {
            if let authUI = auth.authUI {
                AuthenticationViewController(authUI: authUI)
                    .onAppear {
                        // Observe login status
                        Auth.auth().addStateDidChangeListener { _, user in
                            if user != nil {
                                isSignedIn = true
                            }
                        }
                    }
            } else {
                Text("Firebase Auth not set up correctly.")
            }
        }
    }
}
