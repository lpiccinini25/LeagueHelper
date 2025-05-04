//
//  LeagueHelperUnkown.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 5/2/25.
//

import Foundation
import SwiftUI
import Firebase

let COLLECTION_NAME = "articles"
let PAGE_LIMIT = 20

enum ArticleServiceError: Error {
    case mismatchedDocumentError
    case unexpectedError
}

class BareBonesBlogArticle: ObservableObject {
    private let db = Firestore.firestore()
    @State private var showingAlert = false

    @Published var error: Error?
    
    func deleteArticle(article: Article, completion: @escaping (Bool, String) -> Void) {
        db.collection(COLLECTION_NAME).document(article.id).delete() { possibleError in
            if let error = possibleError {
                completion(false, error.localizedDescription)
                print(error.localizedDescription)
            } else {
                completion(true, "success")
            }
        }
    }

    func createArticle(article: Article) -> String {
        var ref: DocumentReference? = nil

        ref = db.collection(COLLECTION_NAME).addDocument(data: [
            "title": article.title,
            "date": article.date,
            "body": article.body,
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

