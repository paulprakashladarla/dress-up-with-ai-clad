
//
//  Persistence.swift
//  dress up with ai
//
//  Created by paulprakash ladarla on 26/09/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Example of adding a preview item
        let newItem = ClothingItem(context: viewContext)
        newItem.timestamp = Date()
        newItem.id = UUID()
        newItem.category = "Top"
        newItem.occasion = "Casual"
        newItem.primaryColorHex = "#FF5733"
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let modelName = "dress_up_with_ai"
        
        // Find and load the data model file manually
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Failed to find data model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load data model file.")
        }

        // Initialize the container with the manually loaded model
        container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
