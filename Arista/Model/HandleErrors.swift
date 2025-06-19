//
//  HandleErrors.swift
//  Arista
//
//  Created by Ordinateur elena on 07/06/2025.
//

import Foundation

struct HandleErrors {
	enum ExerciseError: Error {
		case invalidCategory
		case invalidDuration
		case invalidIntensity
		
		var errorDescription: String? {
			switch self {
			case .invalidCategory:
				return "The category is invalid."
			case .invalidDuration:
				return "The duration is invalid"
			case .invalidIntensity:
				return "The intensity is invalid"
			}
		}
	}
	
	enum PersistenceError: Error {
		case failedToLoadStore(Error)
		case failedToSaveContext(Error)
		
		var errorDescription: String? {
			switch self {
			case .failedToLoadStore(let error):
				return "Failed to load the persistent store: \(error.localizedDescription)"
			case .failedToSaveContext(let error):
				return "Failed to save the context: \(error.localizedDescription)"
			}
		}
	}
}
