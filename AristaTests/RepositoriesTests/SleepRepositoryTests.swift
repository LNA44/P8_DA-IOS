//
//  SleepRepositoryTests.swift
//  AristaTests
//
//  Created by Ordinateur elena on 22/05/2025.
//

import XCTest
import CoreData
@testable import Arista

final class SleepRepositoryTests: XCTestCase {
	//nettoie la base avant chaque test
	private func emptyEntities(context: NSManagedObjectContext) {
		let fetchRequest = Exercise.fetchRequest()
		let objects = try! context.fetch(fetchRequest)
		
		for exercise in objects {
			context.delete(exercise)
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
	
	func test_WhenNoSleepSessionIsInDatabase_GetSleepSessions_ReturnEmptyList() {
		//Given
		let persistenceController = PersistenceController(inMemory: true) //charge un store Core Data temporaire en mémoire
		emptyEntities(context: persistenceController.container.viewContext) // s'assure que la base est vide
		
		let data = SleepRepository(viewContext: persistenceController.container.viewContext)
		//When
		let sleeps = try! data.getSleepSessions()
		//Then
		XCTAssert(sleeps.isEmpty == true)
	}
	//A REVOIR
	func test_WhenAddidOneSleepSessionInDataBase_GetSleepSessions_ReturnAListContainingTheSleepSessions() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let date = Date()
		
		addSleepSession(context: persistenceController.container.viewContext, duration: 22, quality: 3, startDate: date, userFirstName: "Eric", userLastName: "Marceau")
		
		let data = SleepRepository(viewContext: persistenceController.container.viewContext)
		//When
		let sleeps = try! data.getSleepSessions()
		//Then
		XCTAssert(sleeps.isEmpty == false)
		XCTAssertEqual(sleeps.first?.duration, 22)
		XCTAssertEqual(sleeps.first?.quality, 3)
		XCTAssertEqual(sleeps.first?.startDate, date)
	}
	//A REVOIR
	func test_WhenAddingMultipleSleepSessionsInDataBase_GetSleepSessions_ReturnAListContanaingTheSleepSessionsInTheRightOrder() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let date1 = Date()
		let date2 = Date(timeIntervalSinceNow: -(60*60*24))
		let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
		addSleepSession(context: persistenceController.container.viewContext, duration: 22, quality: 3, startDate: date2, userFirstName: "Eric", userLastName: "Marceau")
		addSleepSession(context: persistenceController.container.viewContext, duration: 45, quality: 1, startDate: date1, userFirstName: "Eric", userLastName: "Marceau")
		addSleepSession(context: persistenceController.container.viewContext, duration: 10, quality: 6, startDate: date3, userFirstName: "Eric", userLastName: "Marceau")
		let data = SleepRepository(viewContext: persistenceController.container.viewContext)
		//When
		let sleeps = try! data.getSleepSessions()
		//Then
		XCTAssert(sleeps.count == 3)
		XCTAssertEqual(sleeps[0].duration, 45)
		XCTAssertEqual(sleeps[1].duration, 22)
		XCTAssertEqual(sleeps[2].duration, 10)
	}
}
