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
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
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
	
	func testConvertStringToDateSuccess_NotNil() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		//emptyEntities(context: persistenceController.container.viewContext)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		let dateString = "14:30"
		//When
		let result = viewModel.convertStringToDate(dateString)
		//Then
		XCTAssertNotNil(result)
	}
	
	func testConvertStringToDateSuccess_Nil() {
		//Given
		let persistenceController = PersistenceController(inMemory: true)
		//emptyEntities(context: persistenceController.container.viewContext)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		let dateString = "25:99"
		//When
		let result = viewModel.convertStringToDate(dateString)
		//Then
		XCTAssertNil(result)
	}
	
	func testStartTimeStringUpdatesStartTime() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)

		viewModel.startTimeString = "14:30"
		// Puisque la conversion devrait réussir, startTime devrait changer
		let calendar = Calendar.current
		let components = calendar.dateComponents([.hour, .minute], from: viewModel.startTime)
		XCTAssertEqual(components.hour, 14)
		XCTAssertEqual(components.minute, 30)
	}

	func testStartTimeStringInvalidDateDoesNotUpdateStartTime() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)

		let initialDate = viewModel.startTime
		viewModel.startTimeString = "99:99" // invalide, didSet ne modifie pas startTime
		XCTAssertEqual(viewModel.startTime, initialDate)
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
