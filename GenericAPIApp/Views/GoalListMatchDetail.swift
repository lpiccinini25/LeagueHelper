//
//  GoalListMatchDetail.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/7/25.
//

//
//  GoalRow.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 3/9/25.
//

import SwiftUI

struct GoalListMatchDetail: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var reloadController: ReloadController
    
    @State var goals: [Goal] = []
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    
    let match: Match
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    func printGoal(goal: Goal) -> Void {
        print(goal.title)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Text("🔢 Goals count: \(goals.count)")
                    ForEach($goals, id: \.id) { $goal in
                        GoalRowMatchDetail(goal: goal, match: match)
                            .onAppear {
                                printGoal(goal:goal)
                            }
                    }
                }
            }
            .task {
                fetching = true
                do {
                    print("▶️ about to fetch for user:", userEmail)
                    goals = try await goalService.fetchGoals(userEmail: userEmail)
                    print("goals: \(goals)")
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

