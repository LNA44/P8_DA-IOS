//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Ordinateur elena on 21/05/2025.
//

import Foundation
import CoreData

protocol ExerciseRepositoryProtocol { //permet de le mocker
	func addExercise(category: String, duration: Int, intensity: Int, startDate: Date) throws
}

struct ExerciseRepository: ExerciseRepositoryProtocol {
	//MARK: -Properties
	let viewContext: NSManagedObjectContext
	
	//MARK: -Initialization
	init(viewContext: NSManagedObjectContext) {
		self.viewContext = viewContext
	}
	
	//MARK: -Enumerations
	enum validExerciseCategories: String, CaseIterable {
		case Football
		case Natation
		case Running
		case Marche
		case Cyclisme
	}
	
	//MARK: -Methods
	func getExercise() throws -> [Exercise] {
		let request = Exercise.fetchRequest()
		request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Exercise>(\.startDate, order:.reverse))]
		return try viewContext.fetch(request)
	}
	
	func addExercise(category: String, duration: Int, intensity: Int, startDate: Date) throws {
		guard isValidCategory(category) else {
			throw HandleErrors.ExerciseError.invalidCategory
		}
		guard (0...1440).contains(duration) else {
			throw HandleErrors.ExerciseError.invalidDuration
		}
		guard (0...10).contains(intensity) else {
			throw HandleErrors.ExerciseError.invalidIntensity
		}
		guard startDate <= Date() else { //interdit dates futures
			throw HandleErrors.ExerciseError.invalidStartDate
		}
		let newExercise = Exercise(context: viewContext)
		newExercise.category = category
		newExercise.duration = Int64(duration)
		newExercise.intensity = Int64(intensity)
		newExercise.startDate = startDate
		try viewContext.save()
	}
	
	func isValidCategory(_ category: String) -> Bool {
		return validExerciseCategories.allCases.contains { $0.rawValue == category }
	}
}
