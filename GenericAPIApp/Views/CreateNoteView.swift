//
//  CreateNoteView.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//

/**
 * ArticleEntry is a view for creating a new article.
 */
import SwiftUI
import FirebaseAuth

struct NoteEntry: View {
    @EnvironmentObject var noteService: LeagueHelperNote
    @EnvironmentObject var auth: LeagueHelperAuth
    @EnvironmentObject var reloadController: ReloadController

    @Binding var notes: [Note]
    @Binding var writing: Bool
    
    var match: Match
    
    @State var content = ""
    @State var articleBody = ""

    func submitNote() {
        let userEmail = auth.user?.email ?? "Unknown user"
        let noteId = noteService.createNote(note: Note(
            matchID: match.matchID,
            id: UUID().uuidString,
            playerEmail: userEmail,
            content: content,
            assists: match.assists,
            kills: match.kills,
            deaths: match.deaths,
            win: match.win,
            role: match.role,
            champion: match.champion
        ))

        // As an optimization, instead of reloading all of the entries again, we
        // just _add a new Article in memory_. This makes things appear faster and
        // if the database creation worked fine, upon the next load we would then
        // get the real stored Article.
        //
        // There is some risk here—in the event of an error we might mistakenly
        // provide the wrong impression that the Article was stored when it actually
        // wasn’t. More sophisticated code can look at the published `error` variable
        // in the article service and provide some feedback if that error becomes
        // non-nil.
        notes.append(Note(
            matchID: match.matchID,
            id: noteId,
            playerEmail: userEmail,
            content: content,
            assists: match.assists,
            kills: match.kills,
            deaths: match.deaths,
            win: match.win,
            role: match.role,
            champion: match.champion
        ))

        writing = false
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Note")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 256, maxHeight: .infinity)
                    Button("Submit") {
                        submitNote()
                        reloadController.shouldReload.toggle()
                    }
                    .disabled(content.isEmpty)
                }
            }
            }
        }
    }
