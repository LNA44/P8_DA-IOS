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
	static var lastErrorMessage: String?
	
	//Garde en mémoire pour les previews et tests
	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true) //crée une instance de PersistenceController avec un store Core Data en mémoire, base temporaire avec données effacées dès la fin du test
		let viewContext = result.container.viewContext

		return result
	}()
	
	let container: NSPersistentContainer
	
	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "Arista")
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") //données vont dans un faux fichier donc jamais réellement écrites
		}
		//charge le fichier
		container.loadPersistentStores(completionHandler: {  (storeDescription, error) in
			if let error = error as NSError? {
				PersistenceController.lastErrorMessage = "Erreur chargement Core Data: \(error.localizedDescription)"
				NotificationCenter.default.post(name: .coreDataLoadFailed, object: nil, userInfo: ["error": error])
				/*
				 Typical reasons for an error here include:
				 * The parent directory does not exist, cannot be created, or disallows writing.
				 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
				 * The device is out of space.
				 * The store could not be migrated to the current model version.
				 Check the error message to determine what the actual problem was.
				 */
			}
		})
		if inMemory == false {
			try! DefaultData(viewContext: container.viewContext).apply()
		}
	}
}

