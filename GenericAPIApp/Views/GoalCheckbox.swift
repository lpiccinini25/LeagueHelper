//
//  Checkbox.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/7/25.
//

import SwiftUI

struct GoalCheckbox: View {
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var auth: LeagueHelperAuth
    
    var goal: Goal
    var 

    var body: some View {
        Button(action: { isChecked.toggle() }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square" : "square")
                    .font(.title2)
                if let label = goal.title {
                    Text(label)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .task {
            status = goalService.checkCompletion(goal: goal, matchID: <#T##String#>)
        }
    }
}
