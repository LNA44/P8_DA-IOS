//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//
//  Created by Ordinateur elena on 27/05/2025.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class SleepHistoryViewModelTests: XCTestCase {
	var cancellables = Set<AnyCancellable>()
	
	private func emptyEntities(context: NSManagedObjectContext) {
		let fetchRequest = User.fetchRequest()
		let objects = try! context.fetch(fetchRequest)
		for user in objects {
			context.delete(user)
		}
		let sleepFetchRequest = Sleep.fetchRequest()
		let sleeps = try! context.fetch(sleepFetchRequest)
		for sleep in sleeps {
			context.delete(sleep)
		}
		try! context.save()
	}
	
	private func addSleepSession(context: NSManagedObjectContext, duration: Int, quality: Int, startDate: Date, userFirstName: String, userLastName: String) {
		let newUser = User(context: context)
		newUser.firstName = userFirstName
		newUser.lastName = userLastName
		try! context.save()
		
		let newSleep = Sleep(context: context)
		newSleep.duration = Int64(duration)
		newSleep.quality = Int64(quality)
		newSleep.startDate = startDate
		newSleep.user = newUser
		try! context.save()
	}
	
	func test_WhenNoSleepSessionIsInDatabase_FetchSleepSessions_returnEmptySleepSessions() {
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		emptyEntities(context: context)
		let repository = SleepRepository(viewContext: context)
		let viewModel = SleepHistoryViewModel(repository: repository)
		
		let expectation = XCTestExpectation(description: "Fetch empty sleep session")
		
		viewModel.$sleepSessions
			.sink { session in
				XCTAssertEqual(session, [])
				expectation.fulfill()
			}
			.store(in : &cancellables)
		wait(for: [expectation], timeout: 10)
	}
	
	func test_WhenAddingOneSleepSessionInDatabase_FetchSleepSessions_ReturnAListContainingThisSleepSession() {
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		emptyEntities(context: context)
		
		let date = Date()
		
		addSleepSession(context: context, duration: 25, quality: 7, startDate: date, userFirstName: "Eric", userLastName: "Marceau")
		let repository = SleepRepository(viewContext: context)
		let viewModel = SleepHistoryViewModel(repository: repository)
		
		
		let expectation = XCTestExpectation(description: "Fetch sleep session")
		
		viewModel.$sleepSessions
			.sink { session in
				print("sleepSessions changed: \(session)")
				XCTAssertFalse(session.isEmpty)
				XCTAssertEqual(session.first?.duration, 25)
				XCTAssertEqual(session.first?.quality, 7)
				XCTAssertEqual(session.first?.startDate, date)
				expectation.fulfill()
			}
			.store(in : &cancellables)
		wait(for: [expectation], timeout: 10)
	}
	
	func test_ErrorThrowedByFetchSleepSessions_returnErrorMessage() {
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = SleepHistoryViewModel(repository: SleepRepositoryMock())
		
		let expectation = XCTestExpectation(description: "fetchSleepSessions catch error")
		
		viewModel.$errorMessage
			.dropFirst()
			.sink { errorMessage in
				XCTAssertEqual(errorMessage, "Unknown error happened : Erreur simulée")
				XCTAssertTrue(viewModel.showAlert)
				expectation.fulfill()
			}
			.store(in : &cancellables) 
	}
}
