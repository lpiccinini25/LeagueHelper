//
//  Untitled.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//
import SwiftUI


struct NoteRowFull: View {
    @EnvironmentObject var goalService: LeagueHelperGoal
    @EnvironmentObject var auth: LeagueHelperAuth
    var notes: [Note]
    
    @State private var champIcon: UIImage? = nil
    @State private var completed: Bool = false
    
    private var firstNote: Note {
        notes[0]
    }
    
    private var playerEmail: String {
        auth.user?.email ?? "Unknown user"
    }
    
    private var backgroundColor: Color {
            firstNote.win ? .pistachio : .roseMist
        }
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                VStack {
                    HStack {
                        Text("Playing " + firstNote.role + " as " + firstNote.champion)
                            .font(.headline)
                            .foregroundColor(.black)
                            .bold()
                        
                        Spacer()
                        
                    }
                    
                    HStack {
                        if firstNote.win {
                            Text("Win")
                                .font(.headline)
                                .foregroundColor(.green)
                            Spacer()
                        } else {
                            Text("Loss")
                                .font(.headline)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Label("Assists", systemImage: "hands.sparkles")
                        Spacer()
                        Text(String(firstNote.assists))
                            .bold()
                    }
                    
                    HStack {
                        Label("Kills", systemImage: "crosshairs")
                        Spacer()
                        Text(String(firstNote.kills))
                            .bold()
                    }
                    
                    HStack {
                        Label("Deaths", systemImage: "skull")
                        Spacer()
                        Text(String(firstNote.deaths))
                            .bold()
                    }
                }
                VStack {
                    if let champIcon = champIcon {
                        CircleImage(Icon: champIcon, width: 100, height: 100)
                    }
                }
            }
            ForEach(notes, id: \.id) { note in
                JustNoteRow(note: note)
            }
        }
        .onAppear {
            let urlString = "https://ddragon.leagueoflegends.com/cdn/14.24.1/img/champion/\(firstNote.champion).png"
            fetchChampionIcon(from: urlString) { image in
                champIcon = image
            }
        }
        .padding()
        .background(Color(backgroundColor))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    }
}
