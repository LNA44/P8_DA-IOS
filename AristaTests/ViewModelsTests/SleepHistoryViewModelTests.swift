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
	
	//nettoie la base avant chaque test
	private func emptyEntities(context: NSManagedObjectContext) {
		let fetchRequest = User.fetchRequest()
		let objects = try! context.fetch(fetchRequest)
		for user in objects {
			context.delete(user)
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
		//Clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = SleepHistoryViewModel(context: persistenceController.container.viewContext)
		
		let expectation = XCTestExpectation(description: "Fetch empty sleep session")
		
		viewModel.$sleepSessions //observation du @Published firstName via combine
			.sink { session in //quand valeur de firstName change(même s'il est vide alors le bloc est exécuté)
				XCTAssertEqual(session, [])
				expectation.fulfill()
			}
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		wait(for: [expectation], timeout: 10) //test attend que les deux expectation.fulfill() soient appelés sous max 10sec
	}
	
	func test_WhenAddingOneSleepSessionInDatabase_FetchSleepSessions_ReturnAListContainingThisSleepSession() {
		//Clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = SleepHistoryViewModel(context: persistenceController.container.viewContext)
		let date = Date()
		
		addSleepSession(context: persistenceController.container.viewContext, duration: 25, quality: 7, startDate: date, userFirstName: "Eric", userLastName: "Marceau")
		
		let expectation = XCTestExpectation(description: "Fetch sleep session")
		
		viewModel.$sleepSessions //observation du @Published firstName via combine
			.dropFirst() // ignore la valeur initiale vide lors de l'appel à fetchSleepSessions() dans l'init du VM
			.sink { session in //quand valeur de firstName change(même s'il est vide alors le bloc est exécuté)
				print("sleepSessions changed: \(session)")
				XCTAssertFalse(session.isEmpty)
				XCTAssertEqual(session.first?.duration, 25)
				XCTAssertEqual(session.first?.quality, 7)
				XCTAssertEqual(session.first?.startDate, date)
				expectation.fulfill()
			}
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		viewModel.fetchSleepSessions()
		wait(for: [expectation], timeout: 10) //test attend que les deux expectation.fulfill() soient appelés sous max 10sec
	}
}
