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

enum UserInfoError: LocalizedError {
    case userAlreadyExists
    case userNotFound
    case badRiotIDFormat
    case networkError(Error)
    case httpError(statusCode: Int)
    case decodingError(Error)
    case firestoreError(Error)

    var errorDescription: String? {
        switch self {
        case .userAlreadyExists:
            return "User already exists in Firestore."
        case .userNotFound:
            return "No user document found for that email."
        case .badRiotIDFormat:
            return "Riot ID must be in the format 'username#tagline'."
        case .networkError(let err):
            return "Network error: \(err.localizedDescription)"
        case .httpError(let code):
            return "HTTP error with status code \(code)."
        case .decodingError(let err):
            return "Failed to decode response: \(err.localizedDescription)"
        case .firestoreError(let err):
            return "Firestore error: \(err.localizedDescription)"
        }
    }
}

struct RiotAccount: Codable {
    let puuid: String
}

class LeagueHelperUserInfo: ObservableObject {
    private let db = Firestore.firestore()
    @Published var error: Error?

    func createUser(playerEmail: String, userInfo: UserInfo) async throws {
        do {
            let query = db.collection(UserInformation)
                .whereField("playerEmail", isEqualTo: playerEmail)
            let snapshot = try await query.getDocuments()
            if !snapshot.documents.isEmpty {
                throw UserInfoError.userAlreadyExists
            }
            _ = try await db.collection(UserInformation).addDocument(data: [
                "playerEmail": userInfo.playerEmail,
                "riotID": userInfo.riotID,
                "PUUID": userInfo.PUUID,
                "notes": userInfo.notes
            ])
        } catch let err as UserInfoError {
            throw err
        } catch {
            throw UserInfoError.firestoreError(error)
        }
    }

    func fetchUserInfo(userEmail: String) async throws -> UserInfo {
        do {
            let query = db.collection(UserInformation)
                .whereField("playerEmail", isEqualTo: userEmail)
            let snapshot = try await query.getDocuments()
            guard let doc = snapshot.documents.first else {
                throw UserInfoError.userNotFound
            }
            let data = doc.data()
            guard
                let email = data["playerEmail"] as? String,
                let riotID = data["riotID"] as? String,
                let puuid = data["PUUID"] as? String,
                let notes = data["notes"] as? [String]
            else {
                throw UserInfoError.firestoreError(
                    NSError(domain: "Missing or invalid fields", code: -1)
                )
            }
            return UserInfo(playerEmail: email, riotID: riotID, PUUID: puuid, notes: notes)
        } catch let err as UserInfoError {
            throw err
        } catch {
            throw UserInfoError.firestoreError(error)
        }
    }

    func updateRiotId(playerEmail: String, riotID: String) async throws {
        let components = riotID.split(separator: "#").map(String.init)
        guard components.count == 2,
              !components[0].isEmpty,
              !components[1].isEmpty
        else {
            throw UserInfoError.badRiotIDFormat
        }
        let username = components[0]
        let tagline = components[1]

        do {
            let query = db.collection(UserInformation)
                .whereField("playerEmail", isEqualTo: playerEmail)
            let snapshot = try await query.getDocuments()
            guard let doc = snapshot.documents.first else {
                throw UserInfoError.userNotFound
            }
            let puuid = try await fetchPUUID(username: username, tagline: tagline)
            try await doc.reference.updateData([
                "riotID": riotID,
                "PUUID": puuid
            ])
        } catch let err as UserInfoError {
            throw err
        } catch {
            throw UserInfoError.firestoreError(error)
        }
    }

    func fetchPUUID(username: String, tagline: String) async throws -> String {
        let baseURL = "https://americas.api.riotgames.com"
        guard let url = URL(string: "\(baseURL)/riot/account/v1/accounts/by-riot-id/\(username)/\(tagline)?api_key=\(apiKey)") else {
            throw URLError(.badURL)
        }

        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            if let http = resp as? HTTPURLResponse, http.statusCode != 200 {
                throw UserInfoError.httpError(statusCode: http.statusCode)
            }
            do {
                let decoded = try JSONDecoder().decode(RiotAccount.self, from: data)
                return decoded.puuid
            } catch let decodeError {
                throw UserInfoError.decodingError(decodeError)
            }
        } catch let urlErr as URLError {
            throw UserInfoError.networkError(urlErr)
        } catch {
            throw UserInfoError.networkError(error)
        }
    }
}
