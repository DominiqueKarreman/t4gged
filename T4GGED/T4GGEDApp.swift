//
//  T4GGEDApp.swift
//  T4GGED
//
//  Created by Dominique Karreman on 6/15/25.
//

import SwiftUI
import CoreData

@main
struct T4GGEDApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomePage()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
