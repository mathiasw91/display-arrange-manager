//
//  PersistenceController.swift
//  display-arrange-manager
//
//  Created by Mathias Widera on 02.12.21.
//

import CoreData

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()
    // Storage for Core Data
    let container: NSPersistentContainer

    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Create 10 example programming languages.
        for _ in 0..<10 {
            let arrangement = Arrangement(context: controller.container.viewContext)
            arrangement.name = "Example Arrangement 1"
        }
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "display-arrange-manager")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
