//
//  GoalRow.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/3/25.
//

import SwiftUI

struct GoalRowHome: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var reloadController: ReloadController
    
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    @State private var showingDeleteAlert = false
    @State private var deletionResult = ""
    private var textColor: Color {
        goal.fails.count > goal.successes.count ? .red : .green}
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    func DeleteGoal(completion: @escaping (String) -> Void) {
        goalService.deleteGoal(goal: goal) { success, message in
            if success {
                completion("Goal Deleted")
            } else {
                completion("An Error Occurred while deleting: \(message)")
            }
        }
    }
    
    var goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if goal.quantitative {
                    Text("Achieved \(String(goal.quantity)) " + goal.title)
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
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .padding(.vertical, 8)
                .alert("Delete Goal?", isPresented: $showingDeleteAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        DeleteGoal { message in
                            deletionResult = message
                        }
                        reloadController.shouldReload.toggle()
                    }
                } message: {
                    Text("This action cannot be undone.")
                }
            }
            HStack {
                Text("\(goal.successes.count)")
                  .foregroundColor(.green)
                + Text(" vs ")
                + Text("\(goal.fails.count)")
                  .foregroundColor(.red)
                
                let successes = goal.successes.count
                let failures  = goal.fails.count
                let total     = successes + failures

                let rate: Double = total > 0
                    ? Double(successes) / Double(total)
                    : 0

                Text("\(Int(rate * 100))% success rate")
                    .foregroundColor(textColor)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray4))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    
    }
    
    
}
