//
//  GoalRow.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/3/25.
//

import SwiftUI

struct GoalRowMatchDetail: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var reloadController: ReloadController
    
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    @State private var showingDeleteAlert = false
    @State private var deletionResult = ""
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    var goal: Goal
    var match: Match
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if goal.quantitative {
                    Text("Achieved \(String(goal.quantity)) \(goal.title) ")
                        .foregroundColor(.black)
                        .bold()
                    Spacer()
                } else {
                    Text("\(goal.title)")
                        .foregroundColor(.black)
                        .bold()
                    Spacer()
                }
                GoalCheckbox(goal:goal, matchID: match.matchID)
            }
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    
    }
    
    
}
