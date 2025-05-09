//
//  Untitled.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//

import SwiftUI

struct NoteRowFull: View {
    
    var note: Note
    
    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.role + " as " + note.champion)
                    .font(.headline)
                    .foregroundColor(.black)
                    .bold()
                Spacer()
            }
            
            HStack {
                Text(String(note.id))
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
            
            HStack {
                Label("Assists", systemImage: "hands.sparkles")
                Spacer()
                Text(String(note.assists))
                    .bold()
            }
            
            HStack {
                Label("Kills", systemImage: "crosshairs")
                Spacer()
                Text(String(note.kills))
                    .bold()
            }
            
            HStack {
                Label("Deaths", systemImage: "skull")
                Spacer()
                Text(String(note.deaths))
                    .bold()
            }
            
            JustNoteRow(note: note)
            
        }
        .padding()
        .background(note.win == true ? Color(.green) : Color(.red))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    }
}
