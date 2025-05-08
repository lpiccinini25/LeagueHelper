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
    var matchID: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if goal.quantitative {
                    Text("\(goal.title) \(String(goal.quantity))")
                        .font(.headline)
                        .foregroundColor(.black)
                        .bold()
                    Spacer()
                } else {
                    Text("\(goal.title)")
                        .font(.headline)
                        .foregroundColor(.black)
                        .bold()
                    Spacer()
                }
                GoalCheckbox(goal:goal, matchID: matchID)
            }
        }
        .padding()
        .background(Color(.lightGray))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    
    }
    
    
}
