//
//  SignInView.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/4/25.
//

import SwiftUI
import Firebase
import Foundation

struct SignIn: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var reloadController: ReloadController
    
    @Binding var requestLogin: Bool
    
    @State private var navigate = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome To LeagueHelper, Please Sign In!")
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
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
        
        
        
        
        
        
    }
}
