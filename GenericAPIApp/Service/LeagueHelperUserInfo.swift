//
//  LeagueHelperUser.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/5/25.
//

import Foundation
import SwiftUI
import Firebase

let UserInformation = "userInfo"


struct RiotAccount: Codable {
    let puuid: String
}

class LeagueHelperUserInfo: ObservableObject {
    private let db = Firestore.firestore()

    @State private var showingAlert = false

    @Published var error: Error?

    func createUser(userInfo: UserInfo) -> String {
        var ref: DocumentReference? = nil

        ref = db.collection(UserInformation).addDocument(data: [
            "playerEmail": userInfo.playerEmail,
            "riotID": userInfo.riotID,
            "PUUID": userInfo.PUUID,
            "notes": userInfo.notes,
        ]) { possibleError in
            if let actualError = possibleError {
                self.error = actualError
            }
        }

        return ref?.documentID ?? ""
    }

    func fetchUserInfo(userEmail: String) async throws -> UserInfo {
        var goalQuery = db.collection(UserInformation)
            .whereField("playerEmail", isEqualTo: userEmail)

        let querySnapshot = try await goalQuery.getDocuments()
        
        guard let doc = querySnapshot.documents.first else {
                throw ArticleServiceError.mismatchedDocumentError
        }

        guard let playerEmail = doc.get("playerEmail") as? String,
                  let riotID = doc.get("riotID") as? String,
                  let PUUID = doc.get("PUUID") as? String,
                  let notes = doc.get("notes") as? [String] else {
                throw ArticleServiceError.mismatchedDocumentError
            }


            return UserInfo(
                playerEmail: playerEmail,
                riotID: riotID,
                PUUID: PUUID,
                notes: notes
            )
        }
    
    
    func updateRiotId(playerEmail: String, riotID: String, gameID: String) async throws {
        let userQuery = db.collection(UserInformation)
            .whereField("playerEmail", isEqualTo: playerEmail)
        
        let userSnapshot = try await userQuery.getDocuments()
        
        guard let userRef = userSnapshot.documents.first else {
                throw ArticleServiceError.mismatchedDocumentError
        }
        let usernameAndTagline = riotID.split(separator:"#").map(String.init)
        let username = usernameAndTagline[0]
        let tagline = usernameAndTagline[1]
        
        let PUUID = try await fetchPUUID(username: username, tagline: tagline)
        
        try await userRef.reference.updateData(["riotID": riotID, "PUUID": PUUID])
    }
    
    func fetchPUUID(username: String, tagline: String) async throws -> String {
        let baseURL = "https://americas.api.riotgames.com"
        guard let url = URL(string: "\(baseURL)/riot/account/v1/accounts/by-riot-id/\(username)/\(tagline)?api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(RiotAccount.self, from: data)
        return decoded.puuid
    }
}

