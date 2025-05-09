//
//  NoteRow.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//

import SwiftUI

struct JustNoteRow: View {
    
    var note: Note
    
    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.content)
                    .font(.headline)
                    .foregroundColor(.black)
                    .bold()
                Spacer()
            }
        }
        .padding()
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    
    }
}
