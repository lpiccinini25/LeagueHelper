//
//  LeagueHelperUnkown.swift
//  GenericAPIApp
//
//  Created by Luca Piccinini on 5/2/25.
//

import Foundation
import SwiftUI
import Firebase

let COLLECTION_NAME = "goals"
let PAGE_LIMIT = 20

enum ArticleServiceError: Error {
    case mismatchedDocumentError
    case unexpectedError
}

class LeagueHelperGoal: ObservableObject {
    private let db = Firestore.firestore()

    @State private var showingAlert = false

    @Published var error: Error?
    func deleteGoal(goal: Goal, completion: @escaping (Bool, String) -> Void) {
        db.collection(COLLECTION_NAME).document(goal.id).delete() { possibleError in
            if let error = possibleError {
                completion(false, error.localizedDescription)
                print(error.localizedDescription)
            } else {
                completion(true, "success")
            }
        }
    }

    func createGoal(goal: Goal) -> String {
        var ref: DocumentReference? = nil

        ref = db.collection(COLLECTION_NAME).addDocument(data: [
            "title": goal.title,
            "quantitative": goal.quantitative,
            "quantity": goal.quantity,
            "playerEmail": goal.playerEmail,
            "successes": goal.successes,
            "fails": goal.fails,
        ]) { possibleError in
            if let actualError = possibleError {
                self.error = actualError
            }
        }

        return ref?.documentID ?? ""
    }

    func fetchGoals(userEmail: String) async throws -> [Goal] {
        var goalQuery = db.collection(COLLECTION_NAME)

        let querySnapshot = try await goalQuery.getDocuments()

        return try querySnapshot.documents.map {
                guard let title = $0.get("title") as? String,
                let quantitative = $0.get("quantitative") as? Bool,
                let quantity = $0.get("quantity") as? Int,
                let playerEmail = $0.get("playerEmail") as? String,
                let successes = $0.get("successes") as? [String],
                let fails = $0.get("fails") as? [String]
            else {
                throw ArticleServiceError.mismatchedDocumentError
            }


            return Goal(
                id: $0.documentID,
                title: title,
                quantitative: quantitative,
                quantity: quantity,
                playerEmail: playerEmail,
                successes: successes,
                fails: fails
            )
        }
    }
    
    func updateCompletion(goalID: String, complete: Bool, gameID: String) {
        let goalRef = db.collection(COLLECTION_NAME).document(goalID)
        
        if complete {
            goalRef.updateData([
                "successes": FieldValue.arrayUnion([gameID])
            ]) { error in
                if let error = error{
                    DispatchQueue.main.async {
                        self.error = error
                    }
                    print("Update Failed: \(error.localizedDescription)")
                } else {
                    print("Update Succeeded")
                }
            }
        } else {
            goalRef.updateData([
                "fails": FieldValue.arrayRemove([gameID])
            ]) { error in
                if let error = error{
                    DispatchQueue.main.async {
                        self.error = error
                    }
                    print("Update Failed: \(error.localizedDescription)")
                } else {
                    print("Update Succeeded")
                }
            }
        }
    }
}

