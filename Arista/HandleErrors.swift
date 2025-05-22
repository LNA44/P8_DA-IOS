//
//  HandleErrors.swift
//  Arista
//
//  Created by Ordinateur elena on 21/05/2025.
//

import Foundation

struct HandleErrors {
	enum ExerciseError: Error {
		case invalidCategory
		case invalidDuration
		case invalidIntensity
		case invalidStartDate
		
		var errorDescription: String? {
			switch self {
			case .invalidCategory:
				return "The category is invalid."
			case .invalidDuration:
				return "The duration is invalid"
			case .invalidIntensity:
				return "The intensity is invalid"
			case .invalidStartDate:
				return "The start date is invalid"
			}
		}
	}
}
