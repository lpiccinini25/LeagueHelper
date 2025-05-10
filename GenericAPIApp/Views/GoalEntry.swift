//
//  GoalEntry.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/4/25.
//
import SwiftUI
import FirebaseAuth

struct GoalEntry: View {
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var reloadController: ReloadController
    @Environment(\.dismiss) private var dismiss
    
    @Binding var goals: [Goal]
    @Binding var writing: Bool

    @State private var title = ""
    @State private var isChecked = false
    @State private var quantity = 0

    private var playerEmail: String {
        auth.user?.email ?? "Unknown user"
    }

    func submitGoal() {
        let newGoal = Goal(
            id: UUID().uuidString,
            title: title,
            quantitative: isChecked,
            quantity: quantity,
            playerEmail: playerEmail,
            successes: [],
            fails: []
        )

        let goalID = goalService.createGoal(goal: newGoal)
        goals.append(newGoal) // local cache update

        writing = false
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("Set a Numeric Goal?", isOn: $isChecked)

                    if isChecked {
                        numericGoalFields
                    } else {
                        TextField("Goal Title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding()
            }
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        writing = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        submitGoal()
                        reloadController.shouldReload.toggle()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private var numericGoalFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Goal Type")
                .font(.headline)

            Menu {
                Button("kills") { title = "kills" }
                Button("assists") { title = "assits" }
                Button("")
            } label: {
                Label(title.isEmpty ? "Choose a Goal" : title, systemImage: "chevron.down")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Text("Quantity")
                .font(.headline)

            TextField("Enter number", text: Binding(
                get: { String(quantity) },
                set: { quantity = Int($0) ?? 0 }
            ))
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
        }
    }
}
