//
//  GoalRow.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 3/9/25.
//

import SwiftUI

struct GoalListHome: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var reloadController: ReloadController
    @EnvironmentObject var userService: LeagueHelperUserInfo

    @State var goals: [Goal] = []
    @State var userInfo: UserInfo = UserInfo(
        playerEmail: "",
        riotID: "",
        PUUID: "",
        notes: []
    )
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    func printGoal(goal: Goal) -> Void {
        print(goal.title)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Text("Welcome " + userInfo.riotID)
                Text("🔢 Goals count: \(goals.count)")
                    ForEach($goals, id: \.id) { $goal in
                        GoalRowHome(goal: goal)
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
                        userInfo = try await userService.fetchUserInfo(userEmail: userEmail)
                        fetching = false
                    } catch {
                        self.error = error
                        fetching = false
                    }
            }
        }
    }
}
