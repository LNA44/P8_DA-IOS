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
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let data = UserRepository(viewContext: persistenceController.container.viewContext)
		
		let user = try! data.getUser()
		
		XCTAssertNil(user)
	}
	
	func test_WhenAddingOneUserInDataBase_GetUser_ReturnTheUser() {
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		addUser(context: persistenceController.container.viewContext, firstName: "Eric", lastName: "Marceau")
		let data = UserRepository(viewContext: persistenceController.container.viewContext)
		
		let user = try! data.getUser()
		
		XCTAssertNotNil(user)
		XCTAssertEqual(user?.firstName, "Eric")
		XCTAssertEqual(user?.lastName, "Marceau")
	}
	
	func test_WhenAddingSeveralUsersInDataBase_GetUser_ReturnTheFirstUser() {
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		addUser(context: persistenceController.container.viewContext, firstName: "Eric", lastName: "Marceau")
		addUser(context: persistenceController.container.viewContext, firstName: "Malika", lastName: "Dupont")
		let data = UserRepository(viewContext: persistenceController.container.viewContext)
		
		let user = try! data.getUser()
		
		XCTAssertNotNil(user)
		XCTAssertEqual(user?.firstName, "Eric")
		XCTAssertEqual(user?.lastName, "Marceau")
	}
}
