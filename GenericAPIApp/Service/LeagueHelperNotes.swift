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
let PAGE_LIMIT = 20

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

        ref = db.collection(COLLECTION_NAME).addDocument(data: [
            "content": note.content,
            "matchID": note.matchID,
            "kills": note.kills,
            "assists": article.body,
            "email": article.email,
            "likes": 0,
            "likers": []
        ]) { possibleError in
            if let actualError = possibleError {
                self.error = actualError
            }
        }

        return ref?.documentID ?? ""
    }

    func fetchArticles(showLikedOnly: Bool, userEmail: String) async throws -> [Article] {
        var articleQuery = db.collection(COLLECTION_NAME)
            .order(by: "date", descending: true)
            .limit(to: PAGE_LIMIT)
        if !showLikedOnly {
            articleQuery = db.collection(COLLECTION_NAME)
                .order(by: "date", descending: true)
                .limit(to: PAGE_LIMIT)
        } else {
            articleQuery = db.collection(COLLECTION_NAME)
                .order(by: "date", descending: true)
                .limit(to: PAGE_LIMIT)
                .whereField("likers", arrayContains: userEmail)
        }

        let querySnapshot = try await articleQuery.getDocuments()

        return try querySnapshot.documents.map {
            guard let title = $0.get("title") as? String,

                let dateAsTimestamp = $0.get("date") as? Timestamp,
                let body = $0.get("body") as? String,
                let email = $0.get("email") as? String
            else {
                throw ArticleServiceError.mismatchedDocumentError
            }
            let likes = $0.get("likes") as? Int ?? 0
            let likers = $0.get("likers") as? [String] ?? []

            return Article(
                id: $0.documentID,
                title: title,
                date: dateAsTimestamp.dateValue(),
                body: body,
                email: email,
                likes: likes,
                likers: likers
            )
        }
    }
    
    func updateLikes(articleID: String, increment: Int, liker: String) {
        let articleRef = db.collection(COLLECTION_NAME).document(articleID)
        
        articleRef.updateData([
            "likes": FieldValue.increment(Int64(increment))
        ]) { error in
            if let error = error{
                DispatchQueue.main.async {
                    self.error = error
                }
                print("Oof, error updating likes: \(error.localizedDescription)")
            } else {
                print("Likes updated, yay!")
            }
        }
        
        if increment > 0 {
            articleRef.updateData([
                "likers": FieldValue.arrayUnion([liker])
            ]) { error in
                if let error = error{
                    DispatchQueue.main.async {
                        self.error = error
                    }
                    print("Oof, error updating likes: \(error.localizedDescription)")
                } else {
                    print("Likes updated, yay!")
                }
            }
        } else {
            articleRef.updateData([
                "likers": FieldValue.arrayRemove([liker])
            ]) { error in
                if let error = error{
                    DispatchQueue.main.async {
                        self.error = error
                    }
                    print("Oof, error updating likes: \(error.localizedDescription)")
                } else {
                    print("Likes updated, yay!")
                }
            }
        }
        
    }
}

