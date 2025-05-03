//
//  GenericAPIAppApp.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 2/11/25.
//

import SwiftUI
import FirebaseCore

@main
struct LeagueHelperApp: App {
    @UIApplicationDelegateAdaptor(LeagueHelperAppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
