//
//  AddExerciseViewModelTests.swift
//  AristaTests
//
//  Created by Ordinateur elena on 27/05/2025.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class AddExerciseViewModelTests: XCTestCase {

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
	
	func testAddExerciseSuccess() {
		//Clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)

		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext, repository: ExerciseRepositoryMock(scenario: .success))
		let expectation1 = XCTestExpectation(description: "Wait for errorMessage update")
		let expectation2 = XCTestExpectation(description: "Wait for showAlert update")
		
		viewModel.$errorMessage //observation du @Published exercises via combine
			.sink { message in //quand valeur de exercises change(même s'il est vide alors le bloc est exécuté)
				XCTAssertEqual(message, nil)
				expectation1.fulfill()
			}
		
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		
		viewModel.$showAlert //observation du @Published exercises via combine
			.sink { alert in //quand valeur de exercises change(même s'il est vide alors le bloc est exécuté)
				XCTAssertEqual(alert, false)
				expectation2.fulfill()
			}
		
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		
		let success = viewModel.addExercise()
		XCTAssertTrue(success)
		
		wait(for: [expectation1, expectation2], timeout: 10) //test attend que expectation.fulfill() soit appelé sous max 10sec
	}
	
	func testAddExercise_ExerciseError() {
		//Clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)

		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext, repository: ExerciseRepositoryMock(scenario: .exerciseError))
		let expectation1 = XCTestExpectation(description: "Wait for errorMessage update")
		let expectation2 = XCTestExpectation(description: "Wait for showAlert update")
		
		viewModel.$errorMessage //observation du @Published exercises via combine
			.compactMap { $0 }   // ignore nil (valeur initiale)
			.sink { message in //quand valeur de exercises change(même s'il est vide alors le bloc est exécuté)
				XCTAssertEqual(message, "The duration is invalid")
				expectation1.fulfill()
			}
		
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		
		viewModel.$showAlert //observation du @Published exercises via combine
			.filter { $0 == true }   // ignore false (valeur initiale)
			.sink { alert in //quand valeur de exercises change(même s'il est vide alors le bloc est exécuté)
				XCTAssertEqual(alert, true)
				expectation2.fulfill()
			}
		
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		
		let success = viewModel.addExercise()
		XCTAssertFalse(success)
		
		wait(for: [expectation1, expectation2], timeout: 10) //test attend que expectation.fulfill() soit appelé sous max 10sec
	}
	
	func testAddExercise_UnknownError() {
		//Clean manually all data
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)

		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext, repository: ExerciseRepositoryMock(scenario: .unknownError))
		let expectation1 = XCTestExpectation(description: "Wait for errorMessage update")
		let expectation2 = XCTestExpectation(description: "Wait for showAlert update")
		
		viewModel.$errorMessage //observation du @Published exercises via combine
			.compactMap { $0 }   // ignore nil (valeur initiale)
			.sink { message in //quand valeur de exercises change(même s'il est vide alors le bloc est exécuté)
				XCTAssertTrue(message.starts(with: "Unknown error happened :"))
				expectation1.fulfill()
			}
		
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		
		viewModel.$showAlert //observation du @Published exercises via combine
			.filter { $0 == true }   // ignore false (valeur initiale)
			.sink { alert in //quand valeur de exercises change(même s'il est vide alors le bloc est exécuté)
				XCTAssertEqual(alert, true)
				expectation2.fulfill()
			}
		
			.store(in : &cancellables) //conserve la souscription à @Published pendant tout le test
		
		let success = viewModel.addExercise()
		XCTAssertFalse(success)
		
		wait(for: [expectation1, expectation2], timeout: 10) //test attend que expectation.fulfill() soit appelé sous max 10sec
	}
	
	func testConvertStringToStartDate_validTime_returnsCorrectDate() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		//When
		let result = viewModel.convertStringToStartDate("08:30")
		//Then
		XCTAssertNotNil(result)

		let components = Calendar.current.dateComponents([.hour, .minute], from: result!)
		XCTAssertEqual(components.hour, 8)
		XCTAssertEqual(components.minute, 30)
	}

	func testConvertStringToStartDate_invalidTimeFormat_returnsNil() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		//When
		let result = viewModel.convertStringToStartDate("not a time")
		//Then
		XCTAssertNil(result)
	}
	
	func testConvertStringToStartDate_invalidTime_returnsNil() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		//When
		let result = viewModel.convertStringToStartDate("25:00")
		//Then
		XCTAssertNil(result)
	}

	func testStartTimeString_valid_setsCorrectStartTime() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		//When
		viewModel.startTimeString = "14:00"
		let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.startTime)
		//Then
		XCTAssertEqual(components.hour, 14)
		XCTAssertEqual(components.minute, 0)
	}

	func testStartTimeString_invalid_setsDefaultStartTime() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		//When
		viewModel.startTimeString = "bad input"
		let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: viewModel.startTime)
		XCTAssertEqual(components.year, 2000)
		XCTAssertEqual(components.month, 1)
		XCTAssertEqual(components.day, 1)
		XCTAssertEqual(components.hour, 0)
		XCTAssertEqual(components.minute, 0)
	}
	

	func testDurationStringUpdatesDuration() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
		viewModel.durationString = "45"
		XCTAssertEqual(viewModel.duration, 45)
	}

	func testDurationStringInvalidIntDoesNotUpdateDuration() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
		viewModel.duration = 10
		viewModel.durationString = "abc" // invalide, didSet ne modifie pas duration
		XCTAssertEqual(viewModel.duration, 10)
	}

	func testIntensityStringUpdatesIntensity() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
		viewModel.intensityString = "3"
		XCTAssertEqual(viewModel.intensity, 3)
	}

	func testIntensityStringInvalidIntDoesNotUpdateIntensity() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
		viewModel.intensity = 1
		viewModel.intensityString = "xyz" // invalide
		XCTAssertEqual(viewModel.intensity, 1)
	}
}
