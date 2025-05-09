//
//  NoteListMatchDetail.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//

import SwiftUI

struct NoteListMatchDetail: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var noteService: LeagueHelperNote
    @EnvironmentObject var reloadController: ReloadController
    
    @State var notes: [Note] = []
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    
    let matchID: String
    
    private var userEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    func printGoal(goal: Goal) -> Void {
        print(goal.title)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                    ForEach($notes, id: \.id) { $note in
                        JustNoteRow(note: Note)
                    }
                }
            }
            .task {
                fetching = true
                do {
                    print("▶️ about to fetch for user:", userEmail)
                    goals = try await noteService.fetchGoals(userEmail: userEmail)
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
