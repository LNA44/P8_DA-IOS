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
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		emptyEntities(context: context)
		
		let repository = UserRepository(viewContext: context)
		let viewModel = UserDataViewModel(repository: repository)
		
		let expectation1 = XCTestExpectation(description: "Fetch empty firstName")
		let expectation2 = XCTestExpectation(description: "Fetch empty lastName")
		
		viewModel.$firstName
			.sink { firstName in
				XCTAssertEqual(firstName, "")
				expectation1.fulfill()
			}
			.store(in : &cancellables)
		
		viewModel.$lastName
			.sink { lastName in
				XCTAssertEqual(lastName, "")
				expectation2.fulfill()
			}
		
			.store(in : &cancellables)
		wait(for: [expectation1,expectation2], timeout: 10)
	}
	
	func test_WhenOneUserIsInDatabase_FetchUser_returnFirstNameAndLastName() {
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		emptyEntities(context: context)
		
		addUser(context: context, firstName: "Eric", lastName: "Marceau")
		let repository = UserRepository(viewContext: context)
		let viewModel = UserDataViewModel(repository: repository)
		
		let expectation1 = XCTestExpectation(description: "Fetch firstName")
		let expectation2 = XCTestExpectation(description: "Fetch lastName")
		
		viewModel.$firstName
			.sink { firstName in
				print("Received firstName: \(firstName)")
				XCTAssertEqual(firstName, "Eric")
				expectation1.fulfill()
			}
			.store(in : &cancellables)
		
		viewModel.$lastName
			.sink { lastName in
				XCTAssertEqual(lastName, "Marceau")
				expectation2.fulfill()
			}
		
			.store(in : &cancellables)
		wait(for: [expectation1,expectation2], timeout: 10)
	}
	
	func test_ErrorThrowedByFetchUser_returnUserFirstNameMissing() {
		//Clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let viewModel = UserDataViewModel(repository: UserRepositoryMock(scenario: .noFirstName))
		
		let expectation = XCTestExpectation(description: "fetchUser throws error when no firstName")
		viewModel.$errorMessage
			.dropFirst()
			.sink { errorMessage in
				XCTAssertEqual(errorMessage, "User firstName is missing")
				XCTAssertTrue(viewModel.showAlert)
				expectation.fulfill()
			}
		
			.store(in : &cancellables)
	}
	
	func test_ErrorThrowedByFetchUser_returnUserLastNameMissing() {
		
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let viewModel = UserDataViewModel(repository: UserRepositoryMock(scenario: .noLastName))
		
		let expectation = XCTestExpectation(description: "fetchUser throws error when no lastName")
		viewModel.$errorMessage
			.dropFirst()
			.sink { errorMessage in
				XCTAssertEqual(errorMessage, "User lastName is missing")
				XCTAssertTrue(viewModel.showAlert)
				expectation.fulfill()
			}
		
			.store(in : &cancellables)
	}
	
	func test_ErrorThrowedByFetchUser_returnErrorMessage() {
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = UserDataViewModel(repository: UserRepositoryMock(scenario: .NSError))
		
		let expectation = XCTestExpectation(description: "fetchUser catch error")
		viewModel.$errorMessage
			.dropFirst()
			.sink { errorMessage in
				XCTAssertEqual(errorMessage, "Unknown error happened : Erreur simulée")
				XCTAssertTrue(viewModel.showAlert)
				expectation.fulfill()
			}
		
			.store(in : &cancellables)
	}
	
	func test_CoreDataLoadFailed_NotificationUpdates() {
		let viewModel = UserDataViewModel()
		PersistenceController.lastErrorMessage = "Erreur de chargement simulée"
		
		NotificationCenter.default.post(name: .coreDataLoadFailed, object: nil)
		
		XCTAssertEqual(viewModel.errorMessage, "Erreur de chargement simulée")
		XCTAssertTrue(viewModel.showAlert)
	}
}
