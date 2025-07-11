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
	
	private func emptyEntities(context: NSManagedObjectContext) {
		let fetchRequest = Exercise.fetchRequest()
		let objects = try! context.fetch(fetchRequest)
		
		for exercise in objects {
			context.delete(exercise)
		}
		
		try! context.save()
	}
	
	func testAddExerciseSuccess() {
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext, repository: ExerciseRepositoryMock(scenario1: .success, scenario2: .success))
		let expectation1 = XCTestExpectation(description: "Wait for errorMessage update")
		let expectation2 = XCTestExpectation(description: "Wait for showAlert update")
		
		viewModel.$errorMessage
			.sink { message in
				XCTAssertEqual(message, nil)
				expectation1.fulfill()
			}
		
			.store(in : &cancellables)
		
		viewModel.$showAlert
			.sink { alert in
				XCTAssertEqual(alert, false)
				expectation2.fulfill()
			}
		
			.store(in : &cancellables)
		
		wait(for: [expectation1, expectation2], timeout: 10)
	}
	
	func testAddExercise_ExerciseError() {
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext, repository: ExerciseRepositoryMock(scenario1: .success, scenario2: .exerciseError))
		let expectation1 = XCTestExpectation(description: "Wait for errorMessage update")
		let expectation2 = XCTestExpectation(description: "Wait for showAlert update")
		
		viewModel.$errorMessage
			.compactMap { $0 }
			.sink { message in
				XCTAssertEqual(message, "The duration is invalid")
				expectation1.fulfill()
			}
		
			.store(in : &cancellables)
		
		viewModel.$showAlert
			.filter { $0 == true }
			.sink { alert in
				XCTAssertEqual(alert, true)
				expectation2.fulfill()
			}
		
			.store(in : &cancellables)
		
		viewModel.addExercise()
		
		wait(for: [expectation1, expectation2], timeout: 10)
	}
	
	func testAddExercise_UnknownError() {
		let persistenceController = PersistenceController(inMemory: true)
		emptyEntities(context: persistenceController.container.viewContext)
		
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext, repository: ExerciseRepositoryMock(scenario1: .success, scenario2: .unknownError))
		let expectation1 = XCTestExpectation(description: "Wait for errorMessage update")
		let expectation2 = XCTestExpectation(description: "Wait for showAlert update")
		
		viewModel.$errorMessage
			.compactMap { $0 }
			.sink { message in
				XCTAssertTrue(message.starts(with: "Unknown error happened :"))
				expectation1.fulfill()
			}
		
			.store(in : &cancellables)
		
		viewModel.$showAlert
			.filter { $0 == true }
			.sink { alert in
				XCTAssertEqual(alert, true)
				expectation2.fulfill()
			}
		
			.store(in : &cancellables)
		
		viewModel.addExercise()
		
		wait(for: [expectation1, expectation2], timeout: 10)
	}
	
	func testConvertStringToStartDate_validTime_returnsCorrectDate() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
		let result = viewModel.convertStringToStartDate("08:30")
		
		XCTAssertNotNil(result)
		
		let components = Calendar.current.dateComponents([.hour, .minute], from: result!)
		XCTAssertEqual(components.hour, 8)
		XCTAssertEqual(components.minute, 30)
	}
	
	func testConvertStringToStartDate_invalidTimeFormat_returnsNil() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
		let result = viewModel.convertStringToStartDate("not a time")
		
		XCTAssertNil(result)
	}
	
	func testConvertStringToStartDate_invalidTime_returnsNil() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
		let result = viewModel.convertStringToStartDate("25:00")
		
		XCTAssertNil(result)
	}
	
	func testStartTimeString_valid_setsCorrectStartTime() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
		viewModel.startTimeString = "14:00"
		let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.startTime)
		
		XCTAssertEqual(components.hour, 14)
		XCTAssertEqual(components.minute, 0)
	}
	
	func testStartTimeString_invalid_setsDefaultStartTime() {
		let persistenceController = PersistenceController(inMemory: true)
		let viewModel = AddExerciseViewModel(context: persistenceController.container.viewContext)
		
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
