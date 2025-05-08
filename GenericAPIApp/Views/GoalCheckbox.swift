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
    @EnvironmentObject var reloadController: ReloadController
    
    var goal: Goal
    var matchID: String
    @State private var state: String = "Deciding State..."

    var body: some View {
        numericGoalFields
        .buttonStyle(PlainButtonStyle())
        .task {
            state = await goalService.checkCompletion(goal: goal, matchID: matchID)
        }
    }
    
    private var numericGoalFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal State")
                .font(.headline)

            if goal.quantitative {
                Button() {
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
                
            } else {
                Menu {
                    Button("Accomplished") { state = "Accomplished"
                        goalService.updateCompletion(goal: goal, complete: true, gameID: matchID)
                        reloadController.shouldReload.toggle()
                    }
                    Button("Failed") { state = "Failed"
                        goalService.updateCompletion(goal: goal, complete: false, gameID: matchID)
                        reloadController.shouldReload.toggle()
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
            }
        }
    }
}
