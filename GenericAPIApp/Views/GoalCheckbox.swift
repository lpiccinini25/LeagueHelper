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
    var matchID: String
    @State var state: String = "Deciding State..."

    var body: some View {
        numericGoalFields
        .buttonStyle(PlainButtonStyle())
        .task {
            state = goalService.checkCompletion(goal: goal, matchID: matchID)
        }
    }
    
    private var numericGoalFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set Accomplishment State")
                .font(.headline)

            Menu {
                Button("Accomplished") { state = "Accomplished"
                    
                }
                Button("Failed") { state = "Failed"
                    
                }
            } label: {
                Label(state, systemImage: "chevron.down")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        state == "Accomplished" ? Color.green
                      : state == "Failed"       ? Color.red
                                                : Color.gray
                    )
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .onChange(of: state) {
                Task {
                    if state == "Accomplished" {
                        goalService.updateCompletion(goal: goal, complete: true, gameID: matchID)
                    } else if state == "Failed" {
                        goalService.updateCompletion(goal: goal, complete: false, gameID: matchID)
                    }
                }
            }
        }
    }
}
