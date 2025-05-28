//
//  UserRepositoryTests.swift
//  AristaTests
//
//  Created by Ordinateur elena on 22/05/2025.
//

import XCTest
import CoreData
@testable import Arista

final class UserRepositoryTests: XCTestCase {
	//nettoie la base avant chaque test
	private func emptyEntities(context: NSManagedObjectContext) {
		let fetchRequest = User.fetchRequest()
		let objects = try! context.fetch(fetchRequest)
		
		for users in objects {
			context.delete(users)
		}
		
		try! context.save()
	}
	
	private func addUser(context: NSManagedObjectContext, firstName: String, lastName: String) {
		let newUser = User(context: context)
		newUser.firstName = firstName
		newUser.lastName = lastName
		try! context.save()
	}
	
	func test_WhenNoUserIsInDatabase_GetUser_ReturnNil() {
		//Given
		let persistenceController = PersistenceController(inMemory: true) //charge un store Core Data temporaire en mémoire
		emptyEntities(context: persistenceController.container.viewContext) // s'assure que la base est vide
		
		let data = UserRepository(viewContext: persistenceController.container.viewContext)
		//When
		let user = try! data.getUser()
		//Then
		XCTAssertNil(user)
	}
	//A REVOIR
	func test_WhenAddingOneUserInDataBase_GetUser_ReturnTheUser() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		addUser(context: persistenceController.container.viewContext, firstName: "Eric", lastName: "Marceau")
		
		let data = UserRepository(viewContext: persistenceController.container.viewContext)
		//When
		let user = try! data.getUser()
		//Then
		XCTAssertNotNil(user)
		XCTAssertEqual(user?.firstName, "Eric")
		XCTAssertEqual(user?.lastName, "Marceau")
	}
	//A REVOIR
	func test_WhenAddingSeveralUsersInDataBase_GetUser_ReturnTheFirstUser() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		addUser(context: persistenceController.container.viewContext, firstName: "Eric", lastName: "Marceau")
		addUser(context: persistenceController.container.viewContext, firstName: "Malika", lastName: "Dupont")
		
		let data = UserRepository(viewContext: persistenceController.container.viewContext)
		//When
		let user = try! data.getUser()
		//Then
		XCTAssertNotNil(user)
		XCTAssertEqual(user?.firstName, "Eric")
		XCTAssertEqual(user?.lastName, "Marceau")
	}
}
