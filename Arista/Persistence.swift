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
	static let viewContext = shared.container.viewContext
	static var lastErrorMessage: String?
	
	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext
		
		return result
	}()
	
	let container: NSPersistentContainer
	
	
	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "Arista")
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}
		
		container.loadPersistentStores(completionHandler: {  (storeDescription, error) in
			if let error = error as NSError? {
				PersistenceController.lastErrorMessage = "Erreur chargement Core Data: \(error.localizedDescription)"
				NotificationCenter.default.post(name: .coreDataLoadFailed, object: nil, userInfo: ["error": error])
			}
		})
		if inMemory == false {
			try! DefaultData(viewContext: container.viewContext).apply()
		}
	}
}

