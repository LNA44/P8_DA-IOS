//
//  ExerciseRepositoryTests.swift
//  AristaTests
//
//  Created by Ordinateur elena on 21/05/2025.
//

import XCTest
import CoreData
@testable import Arista

final class ExerciseRepositoryTests: XCTestCase {
	//nettoie la base avant chaque test
	private func emptyEntities(context: NSManagedObjectContext) {
		let fetchRequest = Exercise.fetchRequest()
		let objects = try! context.fetch(fetchRequest)
		
		for exercise in objects {
			context.delete(exercise)
		}
		
		try! context.save()
	}

	private func addExercise(context: NSManagedObjectContext, category: String, duration: Int, intensity: Int, startTime: Date, userFirstName: String, userLastName: String) {
		let newUser = User(context: context)
		newUser.firstName = userFirstName
		newUser.lastName = userLastName
		try! context.save()
		
		let newExercise = Exercise(context: context)
		newExercise.category = category
		newExercise.duration = Int64(duration)
		newExercise.intensity = Int64(intensity)
		newExercise.startTime = startTime
		newExercise.user = newUser
		try! context.save()
	}
	
	func test_WhenNoExerciseIsInDatabase_GetExercise_ReturnEmptyList() {
		//Given
		let persistenceController = PersistenceController(inMemory: true) //charge un store Core Data temporaire en mémoire
		emptyEntities(context: persistenceController.container.viewContext) // s'assure que la base est vide
		
		let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
		//When
		let exercises = try! data.getExercise()
		//Then
		XCTAssert(exercises.isEmpty == true)
	}

	func test_WhenAddidOneExerciseInDataBase_GetExercise_ReturnAListContainingTheExercise() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let date = Date()
		
		addExercise(context: persistenceController.container.viewContext, category: "Football", duration: 10, intensity: 5, startTime: date, userFirstName: "Eric", userLastName: "Marcus")
		
		let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
		//When
		let exercises = try! data.getExercise()
		//Then
		XCTAssert(exercises.isEmpty == false)
		XCTAssert(exercises.first?.category == "Football")
		XCTAssert(exercises.first?.duration == 10)
		XCTAssert(exercises.first?.intensity == 5)
		XCTAssert(exercises.first?.startTime == date)
	}

	func test_WhenAddingMultipleExercisesInDataBase_GetExercise_ReturnAListContanaingTheExercisesInTheRightOrder() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let date1 = Date()
		let date2 = Date(timeIntervalSinceNow: -(60*60*24))
		let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
		addExercise(context: persistenceController.container.viewContext, category: "Football", duration: 10, intensity: 5, startTime: date1, userFirstName: "Erica", userLastName: "Marcusi")
		addExercise(context: persistenceController.container.viewContext, category: "Running", duration: 120, intensity: 1, startTime: date3, userFirstName: "Erice", userLastName: "Marceau")
		addExercise(context: persistenceController.container.viewContext, category: "Fitness", duration: 30, intensity: 5, startTime: date2, userFirstName: "Frédéric", userLastName: "Marcus")
		
		let data = ExerciseRepository(viewContext: persistenceController.container.viewContext)
		//When
		let exercises = try! data.getExercise()
		//Then
		XCTAssert(exercises.count == 3)
		XCTAssert(exercises[0].category == "Football")
		XCTAssert(exercises[1].category == "Fitness")
		XCTAssert(exercises[2].category == "Running")
	}

	//NEW
	func testAddExerciseSuccess() throws {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let repository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
		let date = Date()
		//When
		try repository.addExercise(category: "Football", duration: 10, intensity: 5, startTime: date)
		//Then
		let fetchRequest = Exercise.fetchRequest()
		let exercise = try persistenceController.container.viewContext.fetch(fetchRequest)
		XCTAssertEqual(exercise.count, 1)
		XCTAssertEqual(exercise[0].category, "Football")
		XCTAssertEqual(exercise[0].duration, 10)
		XCTAssertEqual(exercise[0].intensity, 5)
		XCTAssertEqual(exercise[0].startTime, date)
	}
	//NEW
	func testAddExerciseInvalidCategory() throws {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let repository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
		let date = Date()
		//When & Then
		do {
			try repository.addExercise(category: "Swimming", duration: 10, intensity: 5, startTime: date)
			XCTFail("Expected to throw an error but it didn't")
		} catch let error as HandleErrors.ExerciseError{
			XCTAssertEqual(error,.invalidCategory)
		} catch {
			XCTFail("Unknown error happened \(error)")
		}
		let fetchRequest = Exercise.fetchRequest()
		let exercise = try persistenceController.container.viewContext.fetch(fetchRequest)
		XCTAssertTrue(exercise.isEmpty)
	}
	//NEW
	func testAddExerciseInvalidDuration() throws {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let repository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
		let date = Date()
		//When & Then
		do {
			try repository.addExercise(category: "Football", duration: 3000, intensity: 5, startTime: date)
			XCTFail("Expected to throw an error but it didn't")
		} catch let error as HandleErrors.ExerciseError{
			XCTAssertEqual(error,.invalidDuration)
		} catch {
			XCTFail("Unknown error happened \(error)")
		}
		let fetchRequest = Exercise.fetchRequest()
		let exercise = try persistenceController.container.viewContext.fetch(fetchRequest)
		XCTAssertTrue(exercise.isEmpty)
	}
	//NEW
	func testAddExerciseInvalidIntensity() throws {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let repository = ExerciseRepository(viewContext: persistenceController.container.viewContext)
		let date = Date()
		//When & Then
		do {
			try repository.addExercise(category: "Football", duration: 10, intensity: 11, startTime: date)
			XCTFail("Expected to throw an error but it didn't")
		} catch let error as HandleErrors.ExerciseError{
			XCTAssertEqual(error,.invalidIntensity)
		} catch {
			XCTFail("Unknown error happened \(error)")
		}
		let fetchRequest = Exercise.fetchRequest()
		let exercise = try persistenceController.container.viewContext.fetch(fetchRequest)
		XCTAssertTrue(exercise.isEmpty)
	}
}
