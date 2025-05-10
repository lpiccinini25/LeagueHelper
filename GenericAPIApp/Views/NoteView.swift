//
//  NoteView.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var noteService: LeagueHelperNote
    
    @Binding var goToNotes: Bool
    
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                NoteListFull()
            }
        }
    }
    
    
    
}
