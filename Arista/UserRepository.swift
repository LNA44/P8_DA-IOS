//
//  UserRepository.swift
//  Arista
//
//  Created by Ordinateur elena on 20/05/2025.
//

import Foundation
import CoreData

struct UserRepository {
	//MARK: -Properties
	let viewContext: NSManagedObjectContext
	
	//MARK: -Initialization
	init(viewContext: NSManagedObjectContext) {
		self.viewContext = viewContext
	}
	
	//MARK: -Methods
	func getUser() throws -> User? {
		let request: NSFetchRequest<User> = User.fetchRequest()
		request.fetchLimit = 1
		return try viewContext.fetch(request).first
	}
}
