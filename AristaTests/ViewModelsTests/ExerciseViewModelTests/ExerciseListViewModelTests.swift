//
//  ExerciseListViewModelTests.swift
//  AristaTests
//
//  Created by Ordinateur elena on 22/05/2025.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class ExerciseListViewModelTests: XCTestCase {
	var cancellables = Set<AnyCancellable>()
	
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
	
	
	func test_WhenNoExerciseIsInDatabase_FetchExercise_returnEmptyList() {
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		emptyEntities(context: context)
		let repository = ExerciseRepository(viewContext: context)
		let viewModel = ExerciseListViewModel(repository: repository)
		let expectation = XCTestExpectation(description: "Fetch empty list of exercises")
		
		viewModel.$exercises
			.sink { exercises in
				XCTAssertTrue(exercises.isEmpty)
				expectation.fulfill()
			}
		
			.store(in : &cancellables)
		wait(for: [expectation], timeout: 10)
	}
	
	func test_WhenAddingOneExerciseInDatabase_FetchExercise_ReturnAListContainingThisExercise() {
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		
		emptyEntities(context: context)
		let date = Date()
		addExercise(context: persistenceController.container.viewContext, category: "Football", duration:10, intensity: 5, startTime: date, userFirstName: "Eric", userLastName: "Marcus")
		let repository = ExerciseRepository(viewContext: context)
		
		let viewModel = ExerciseListViewModel(repository: repository)
		let expectation = XCTestExpectation(description: "Fetch empty list of exercise")
		
		viewModel.$exercises
			.sink { exercises in
				XCTAssert(exercises.isEmpty == false)
				XCTAssert(exercises.first?.category == "Football")
				XCTAssert(exercises.first?.duration == 10)
				XCTAssert(exercises.first?.intensity == 5)
				XCTAssert(exercises.first?.startTime == date)
				expectation.fulfill()
			}
			.store(in: &cancellables)
		wait(for: [expectation], timeout: 10)
	}
	
	func test_WhenAddingMultipleExerciseInDatabase_FetchExercise_ReturnAListContainingTheExerciseInTheRightOrder() {
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		
		emptyEntities(context: context)
		let date1 = Date()
		let date2 = Date(timeIntervalSinceNow: -(60*60*24))
		let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))
		
		addExercise(context: context, category: "Football", duration: 10, intensity: 5,startTime: date1, userFirstName: "Ericn", userLastName: "Marcusi")
		addExercise(context: context, category: "Running", duration: 120, intensity: 1, startTime: date3, userFirstName: "Ericb", userLastName: "Marceau")
		addExercise(context: context, category: "Fitness", duration: 30, intensity: 5, startTime: date2, userFirstName: "Frédericp", userLastName: "Marcus")
		
		let repository = ExerciseRepository(viewContext: context)
		let viewModel = ExerciseListViewModel(repository: repository)
		let expectation = XCTestExpectation(description: "fetch empty list of exercise")
		
		viewModel.$exercises
			.sink { exercises in
				XCTAssert(exercises.count == 3)
				XCTAssert(exercises[0].category == "Football")
				XCTAssert(exercises[1].category == "Fitness")
				XCTAssert(exercises[2].category == "Running")
				expectation.fulfill()
			}
			.store(in: &cancellables)
		wait(for: [expectation], timeout: 10)
	}
	
	func test_ErrorThrowedByFetchExercises_returnErrorMessage() {
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		emptyEntities(context: context)
		
		let viewModel = ExerciseListViewModel(repository: ExerciseRepositoryMock(scenario1: .unknownError, scenario2: .success))
		
		let expectation = XCTestExpectation(description: "fetchExercises catch error")
		
		viewModel.$errorMessage
			.sink { errorMessage in
				XCTAssertEqual(errorMessage, "Unknown error happened : Erreur simulée")
				XCTAssertTrue(viewModel.showAlert)
				expectation.fulfill()
			}
			.store(in: &cancellables)
		wait(for: [expectation], timeout: 10)
	}
	
	func test_Reload_Success() {
		let persistenceController = PersistenceController(inMemory: true)
		let context = persistenceController.container.viewContext
		emptyEntities(context: context)
		let viewModel = ExerciseListViewModel(repository: ExerciseRepositoryMock(scenario1: .success, scenario2: .success))
		
		viewModel.reload()
		
		XCTAssertEqual(viewModel.exercises.count, 1)
		XCTAssertEqual(viewModel.exercises[0].duration, 10)
		XCTAssertEqual(viewModel.exercises[0].intensity, 10)
		XCTAssertFalse(viewModel.showAlert)
		XCTAssertNil(viewModel.errorMessage)
	}
}
