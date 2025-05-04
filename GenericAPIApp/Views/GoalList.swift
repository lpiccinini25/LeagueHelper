//
//  GoalRow.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 3/9/25.
//

import SwiftUI

struct GoalList: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var reloadController: ReloadController
    
    @Binding var requestLogin: Bool
    @State var goals: [Goal]
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    private func goalListView(userEmail: String) -> some View {
        List($goals, id: \.id) { $goal in
                    GoalRow(goal: goal)
        }
    }
    
    var body: some View {
        
        ScrollView {
            ForEach(goals) { goal in
                GoalRow(goal: goal)
            }
        }
    }
}
