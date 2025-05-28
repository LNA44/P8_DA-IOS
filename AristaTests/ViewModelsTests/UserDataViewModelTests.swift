//
//  UserDataViewModelTests.swift
//  AristaTests
//
//  Created by Ordinateur elena on 23/05/2025.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class UserDataViewModelTests: XCTestCase {
	var cancellables = Set<AnyCancellable>()
	
	//nettoie la base avant chaque test
	private func emptyEntities(context: NSManagedObjectContext) {
		let fetchRequest = User.fetchRequest()
		let objects = try! context.fetch(fetchRequest)
		for user in objects {
			context.delete(user)
		}
		try! context.save()
	}
	
	private func addUser(context: NSManagedObjectContext, firstName: String, lastName: String) {
		let newUser = User(context: context)
		newUser.firstName = firstName
		newUser.lastName = lastName
		try! context.save()
	}
	
	func test_WhenNoUserIsInDatabase_FetchUser_returnEmptyFirstNameAndLastName() {
		//Clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = UserDataViewModel(context: persistenceController.container.viewContext)
		
		let expectation1 = XCTestExpectation(description: "Fetch empty firstName")
		let expectation2 = XCTestExpectation(description: "Fetch empty lastName")
		
		viewModel.$firstName //observation du @Published firstName via combine
			.sink { firstName in //quand valeur de firstName change(même s'il est vide alors le bloc est exécuté)
				XCTAssertEqual(firstName, "")
				expectation1.fulfill()
			}
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		
		viewModel.$lastName //observation du @Published lastName via combine
			.sink { lastName in //quand valeur de lastName change(même s'il est vide alors le bloc est exécuté)
				XCTAssertEqual(lastName, "")
				expectation2.fulfill()
			}
		
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		wait(for: [expectation1,expectation2], timeout: 10) //test attend que les deux expectation.fulfill() soient appelés sous max 10sec
	}
}
