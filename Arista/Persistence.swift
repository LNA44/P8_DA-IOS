//
//  Persistence.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import CoreData
//Gère l'accès et l'instanciation de la base CoreData
struct PersistenceController {
    static let shared = PersistenceController()

	//Garde en mémoire pour les previews et tests
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true) //crée une instance de PersistenceController avec un store Core Data en mémoire, base temporaire avec données effacées dès la fin du test
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
		print("PersistenceController init - inMemory: \(inMemory)")
        container = NSPersistentContainer(name: "Arista") //charge le modèle Arista
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") //données vont dans un faux fichier donc jamais réellement écrites
        }
		//charge le fichier
        container.loadPersistentStores(completionHandler: {  (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true //viewContext principal recoit automatiquement les changements d'autres contextes en arrière plan et se maj seul
		if inMemory == false {
			try! DefaultData(viewContext: container.viewContext).apply()
		}
    }
}

