//
//  ExerciseRepositoryMock.swift
//  AristaTests
//
//  Created by Ordinateur elena on 27/05/2025.
//

import Foundation
@testable import Arista

enum MockScenarioFetchExerciseRepository {
	case success
	case exerciseError
	case unknownError
}

enum MockScenarioGetExerciseRepository {
	case success
	case unknownError
}

struct ExerciseRepositoryMock: ExerciseRepositoryProtocol {
	let scenario1: MockScenarioGetExerciseRepository
	let scenario2: MockScenarioFetchExerciseRepository
	
	func getExercise() throws -> [Exercise] {
		switch scenario1 {
		case .success:
			let exercise = Exercise(context: PersistenceController().container.viewContext)
			exercise.duration = 10
			exercise.intensity = 10
			exercise.startTime = Date()
			let exercises = [exercise]
			return exercises
		case .unknownError:
			throw NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "Erreur simulée"])
		}
	}
	
	func addExercise(category: String, duration: Int, intensity: Int, startTime: Date) throws {
		switch scenario2 {
		case .success:
			// Simule un ajout réussi, ne lève pas d’erreur
			return
		case .exerciseError:
			throw HandleErrors.ExerciseError.invalidDuration
		case .unknownError:
			throw NSError(domain: "Test", code: 1, userInfo: nil)
		}
	}
}
