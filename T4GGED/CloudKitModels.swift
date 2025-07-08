//  CloudKitModels.swift
//  Models and helpers for users, invites, and friendships with CloudKit

import Foundation
import CloudKit
import SwiftUI

// MARK: - CloudKit Entity Models

// User Record type
struct CKAppUser: Identifiable {
    let recordID: CKRecord.ID
    var id: CKRecord.ID { recordID }
    var username: String
    var avatarURL: URL?
}

// Friend Invite Record type
struct CKFriendInvite: Identifiable {
    let recordID: CKRecord.ID
    var id: CKRecord.ID { recordID }
    let fromUser: CKRecord.Reference
    let toUser: CKRecord.Reference
    var status: String // "pending", "accepted", "declined"
    let sentAt: Date
}

// (Optional) Friendship Record type, can be used if needed
struct CKFriendship: Identifiable {
    let recordID: CKRecord.ID
    var id: CKRecord.ID { recordID }
    let userA: CKRecord.Reference
    let userB: CKRecord.Reference
    let since: Date
}

// MARK: - CloudKit Helper

final class CloudKitUserManager: ObservableObject {
    static let userRecordType = "User"
    static let inviteRecordType = "FriendInvite"
    static let friendshipRecordType = "Friendship"
    
    let container = CKContainer.default()
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // Fetch user's iCloud identity (for default fields)
    func fetchCurrentUserIdentity(completion: @escaping (CKRecord.ID?, String?) -> Void) {
        container.fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                completion(nil, nil)
                return
            }
            self.container.discoverUserIdentity(withUserRecordID: recordID) { identity, error in
                if let identity = identity, error == nil {
                    let defaultName = identity.nameComponents?.givenName ?? "User"
                    completion(recordID, defaultName)
                } else {
                    completion(recordID, "User")
                }
            }
        }
    }

    // Create User record with iCloud info
    func createUserIfNeeded(username: String? = nil, completion: @escaping (Result<CKAppUser, Error>) -> Void) {
        fetchCurrentUserIdentity { recordID, defaultName in
            guard let recordID else {
                completion(.failure(NSError(domain: "No iCloud ID", code: 0)))
                return
            }
            // Check if user record exists
            self.publicDB.fetch(withRecordID: recordID) { record, error in
                if let record = record {
                    // Already exists, return it
                    let user = CKAppUser(recordID: record.recordID, username: record["username"] as? String ?? defaultName ?? "User", avatarURL: nil)
                    completion(.success(user))
                } else {
                    // Create new record
                    let userRecord = CKRecord(recordType: Self.userRecordType, recordID: recordID)
                    userRecord["username"] = username ?? defaultName ?? "User"
                    self.publicDB.save(userRecord) { savedRecord, saveError in
                        if let savedRecord = savedRecord {
                            let user = CKAppUser(recordID: savedRecord.recordID, username: savedRecord["username"] as? String ?? defaultName ?? "User", avatarURL: nil)
                            completion(.success(user))
                        } else {
                            completion(.failure(saveError ?? NSError(domain: "Unknown error", code: 1)))
                        }
                    }
                }
            }
        }
    }
}

// USAGE SAMPLE (not included in target):
// let manager = CloudKitUserManager()
// manager.createUserIfNeeded { result in
//     switch result {
//     case .success(let user):
//         print("Created user: \(user.username)")
//     case .failure(let error):
//         print("Failed: \(error)")
//     }
// }
