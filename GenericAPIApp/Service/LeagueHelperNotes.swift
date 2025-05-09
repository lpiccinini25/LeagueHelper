//
//  LeagueHelperNotes.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/8/25.
//

import Foundation
import SwiftUI
import Firebase

let notes = "notes"

class LeagueHelperNotes: ObservableObject {
    private let db = Firestore.firestore()
    @State private var showingAlert = false

    @Published var error: Error?
    
    func deleteNote(note: Note, completion: @escaping (Bool, String) -> Void) {
        db.collection(notes).document(note.id).delete() { possibleError in
            if let error = possibleError {
                completion(false, error.localizedDescription)
                print(error.localizedDescription)
            } else {
                completion(true, "success")
            }
        }
    }

    func createNote(note: Note) -> String {
        var ref: DocumentReference? = nil

        ref = db.collection(notes).addDocument(data: [
            "content": note.content,
            "matchID": note.matchID,
            "kills": note.kills,
            "assists": note.assists,
            "deaths": note.deaths,
            "win": note.win,
            "role": note.role,
            "champion": note.champion,
        ]) { possibleError in
            if let actualError = possibleError {
                self.error = actualError
            }
        }

        return ref?.documentID ?? ""
    }

    func fetchNotes(userEmail: String) async throws -> [Note] {
        var articleQuery = db.collection(notes)
            .order(by: "date", descending: true)
            .limit(to: PAGE_LIMIT)

        let querySnapshot = try await articleQuery.getDocuments()

        return try querySnapshot.documents.map {
            guard let content = $0.get("content") as? String,
                  let playerEmail = $0.get("playerEmail") as? String,
                  let matchID = $0.get("matchID") as? String,
                  let kills = $0.get("kills") as? Int,
                  let deaths = $0.get("deaths") as? Int,
                  let win = $0.get("win") as? Bool,
                  let assists = $0.get("assists") as? Int,
                  let role = $0.get("role") as? String,
                  let champion = $0.get("champion") as? String
            else {
                throw ArticleServiceError.mismatchedDocumentError
            }

            return Note(
                matchID: matchID,
                id: $0.documentID,
                playerEmail: playerEmail,
                content: content,
                assists: assists,
                kills: kills,
                deaths: deaths,
                win: win,
                role: role,
                champion: champion
            )
        }
    }
}

