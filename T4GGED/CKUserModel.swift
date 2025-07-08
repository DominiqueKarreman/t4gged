//
//  CKUserModel.swift
//  T4GGED
//
//  Created by Dominique Karreman on 7/8/25.
//

import Foundation
import CoreData

extension CKUser {
    convenience init(recordName: String, username: String?, avatarData: Data?, email: String?, recordPasscode: String?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.recordName = recordName
        self.username = username
        self.avatarData = avatarData
        self.email = email
        self.recordPasscode = recordPasscode
    }
}

extension CKUser {
    @MainActor
    func save() {
        let context = self.managedObjectContext ?? PersistenceController.shared.container.viewContext
        do {
            try context.save()
            print("CKUser saved to Core Data!")
        } catch {
            print("Error saving CKUser to Core Data: \(error.localizedDescription)")
        }
    }
}
