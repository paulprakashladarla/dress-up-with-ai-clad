//
//  dress_up_with_aiApp.swift
//  dress up with ai
//
//  Created by paulprakash ladarla on 26/09/25.
//

import SwiftUI
import CoreData

@main
struct dress_up_with_aiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
