//
//  ExerciseRepositoryMock.swift
//  AristaTests
//
//  Created by Ordinateur elena on 27/05/2025.
//

import Foundation
@testable import Arista

enum MockScenarioExerciseRepository {
	case success
	case exerciseError
	case unknownError
}

struct ExerciseRepositoryMock: ExerciseRepositoryProtocol {
	let scenario: MockScenarioExerciseRepository
	
	func addExercise(category: String, duration: Int, intensity: Int, startTime: Date) throws {
		switch scenario {
		case .success:
			// Simule un ajout réussi, ne lève pas d’erreur
			return
		case .exerciseError:
			throw HandleErrors.ExerciseError.invalidDuration
		case .unknownError:
			// Simule une erreur inconnue
			throw NSError(domain: "Test", code: 1, userInfo: nil)
		}
	}
}
