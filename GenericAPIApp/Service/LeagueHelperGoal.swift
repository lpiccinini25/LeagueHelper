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
        let goalQuery = db.collection(COLLECTION_NAME)
            .whereField("playerEmail", isEqualTo: userEmail)
        print("fetching")
        
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
    
    func updateGoalsQuantitative(userEmail: String, MatchList: [Match]) async throws {
        var goalQuery = db.collection(COLLECTION_NAME)
            .whereField("playerEmail", isEqualTo: userEmail)
            .whereField("quantitative", isEqualTo: true)
        
        
        let querySnapshot = try await goalQuery.getDocuments()
        
        for doc in querySnapshot.documents {
            let ref = doc.reference
            let goal = doc.get("title") as? String ?? "(no title)"
            let threshold = doc.get("quantity") as? Int ?? 0
            
            for match in MatchList {
                
                let value: Int
                switch goal {
                case "kills":
                    value = match.kills
                case "assists":
                    value = match.assists
                case "creep score":
                    value = match.totalMinionsKilled
                default:
                    continue    // unknown field → skip
                }
                
                print(goal)
                print(value)
                
                if value >= threshold {
                    ref.updateData([
                        "successes": FieldValue.arrayUnion([match.matchID]),
                        "fails": FieldValue.arrayRemove([match.matchID])
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
                    ref.updateData([
                        "fails": FieldValue.arrayUnion([match.matchID]),
                        "successes": FieldValue.arrayRemove([match.matchID])
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
    }
    
    func updateCompletion(goal: Goal, complete: Bool, gameID: String) {
        let goalRef = db.collection(COLLECTION_NAME).document(goal.id)
        
        if complete {
            goalRef.updateData([
                "successes": FieldValue.arrayUnion([gameID]),
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
        } else {
            goalRef.updateData([
                "fails": FieldValue.arrayUnion([gameID]),
                "successes": FieldValue.arrayRemove([gameID])
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
    
    func checkCompletion(goal: Goal, matchID: String) async -> String {
        let docRef = db.collection(COLLECTION_NAME).document(goal.id)
        do {
            // This suspends until the document arrives
            let snapshot = try await docRef.getDocument()
            
            let successes = snapshot.get("successes") as? [String] ?? []
            let fails     = snapshot.get("fails")     as? [String] ?? []
            
            if successes.contains(matchID) { return "Accomplished" }
            if fails.contains(matchID)     { return "Failed"       }
            return "Not Classified"
        } catch {
            print("Error fetching:", error)
            return "Error"
        }
    }
}

