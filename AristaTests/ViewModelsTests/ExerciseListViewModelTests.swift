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
	
	//nettoie la base avant chaque test
	private func emptyEntities(context: NSManagedObjectContext) {
		let fetchRequest = Exercise.fetchRequest()
		let objects = try! context.fetch(fetchRequest)
		
		for exercise in objects {
			context.delete(exercise)
		}
		
		try! context.save()
	}

	private func addExercise(context: NSManagedObjectContext, category: String, duration: Int, intensity: Int, startDate: Date, userFirstName: String, userLastName: String) {
		let newUser = User(context: context)
		newUser.firstName = userFirstName
		newUser.lastName = userLastName
		try! context.save()
		
		let newExercise = Exercise(context: context)
		newExercise.category = category
		newExercise.duration = Int64(duration)
		newExercise.intensity = Int64(intensity)
		newExercise.startDate = startDate
		newExercise.user = newUser
		try! context.save()
	}
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	func test_WhenNoExerciseIsInDatabase_FetchExercise_returnEmptyList() {
		//Clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = ExerciseListViewModel(context: persistenceController.container.viewContext)
		let expectation = XCTestExpectation(description: "Fetch empty list of exercises")
		
		viewModel.$exercises //observation du @Published exercises via combine
			.sink { exercises in //quand valeur de exercises change(même s'il est vide alors le bloc est exécuté)
				XCTAssertTrue(exercises.isEmpty)
				expectation.fulfill()
			}
		
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		wait(for: [expectation], timeout: 10) //test attend que expectation.fulfill() soit appelé sous max 10sec
	}
	//A REVOIR
	func test_WhenAddingOneExerciseInDatabase_FetchExercise_ReturnAListContainingThisExercise() {
		//clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let date = Date()
		addExercise(context: persistenceController.container.viewContext, category: "Football", duration:10, intensity: 5, startDate: date, userFirstName: "Eric", userLastName: "Marcus")
		
		let viewModel = ExerciseListViewModel(context: persistenceController.container.viewContext)
		let expectation = XCTestExpectation(description: "Fetch empty list of exercise")
		
		viewModel.$exercises
			.sink { exercises in
				XCTAssert(exercises.isEmpty == false)
				XCTAssert(exercises.first?.category == "Football")
				XCTAssert(exercises.first?.duration == 10)
				XCTAssert(exercises.first?.intensity == 5)
				XCTAssert(exercises.first?.startDate == date)
				expectation.fulfill()
			}
			.store(in: &cancellables)
			wait(for: [expectation], timeout: 10)
	}
	//A REVOIR
	func test_WhenAddingMultipleExerciseInDatabase_FetchExercise_ReturnAListContainingTheExerciseInTheRightOrder() {
		// clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		let date1 = Date()
		let date2 = Date(timeIntervalSinceNow: -(60*60*24))
		let date3 = Date(timeIntervalSinceNow: -(60*60*24*2))

		addExercise(context: persistenceController.container.viewContext, category: "Football", duration: 10, intensity: 5,startDate: date1, userFirstName: "Ericn", userLastName: "Marcusi")
		addExercise(context: persistenceController.container.viewContext, category: "Running", duration: 120, intensity: 1, startDate: date3, userFirstName: "Ericb", userLastName: "Marceau")
		addExercise(context: persistenceController.container.viewContext, category: "Fitness", duration: 30, intensity: 5, startDate: date2, userFirstName: "Frédericp", userLastName: "Marcus")
		
		let viewModel = ExerciseListViewModel(context: persistenceController.container.viewContext)
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
}
