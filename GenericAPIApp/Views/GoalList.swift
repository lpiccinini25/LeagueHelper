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
    
    @State var goals: [Goal] = []
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                    ForEach($goals, id: \.id) { $goal in
                        GoalRow(goal: goal)
                    }
                }
            }
            .task {
                fetching = true
                do {
                    goals = try await goalService.fetchGoals(userEmail: userEmail)
                    fetching = false
                } catch {
                    self.error = error
                    fetching = false
                }
            }
            .onChange(of: reloadController.shouldReload) {
                Task {
                    do {
                        goals = try await goalService.fetchGoals(userEmail: userEmail)
                        fetching = false
                    } catch {
                        self.error = error
                        fetching = false
                    }
            }
        }
    }
}
