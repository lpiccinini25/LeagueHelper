//
//  NoteListFull.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//

import SwiftUI

struct NoteListFull: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var noteService: LeagueHelperNote
    @EnvironmentObject var reloadController: ReloadController
    
    @State var notes: [Note] = []
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
        let grouped: [String: [Note]] = Dictionary(grouping: notes, by: \.matchID)
        let groupedNotes: [[Note]] = Array(grouped.values)
        ScrollView {
            LazyVStack {
                ForEach(groupedNotes, id: \.self) { group in
                    NoteRowFull(notes: group)
                    }
                }
            }
            .task {
                fetching = true
                do {
                    print("▶️ about to fetch for user:", userEmail)
                    notes = try await noteService.fetchNotes(userEmail: userEmail)
                    fetching = false
                } catch {
                    self.error = error
                    fetching = false
                }
            }
            .onChange(of: reloadController.shouldReload) {
                Task {
                    do {
                        notes = try await noteService.fetchNotes(userEmail: userEmail)
                        fetching = false
                    } catch {
                        self.error = error
                        fetching = false
                    }
            }
        }
    }
}
