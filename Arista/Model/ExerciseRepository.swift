//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Ordinateur elena on 07/06/2025.
//

import Foundation
import CoreData

protocol ExerciseRepositoryProtocol {
	func getExercise() throws -> [Exercise]
	func addExercise(category: String, duration: Int, intensity: Int, startTime: Date) throws
}

struct ExerciseRepository: ExerciseRepositoryProtocol {
	//MARK: -Properties
	let viewContext: NSManagedObjectContext
	
	//MARK: -Initialization
	init(viewContext: NSManagedObjectContext? = nil) {
		self.viewContext = viewContext ?? PersistenceController.viewContext
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
		request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Exercise>(\.startTime, order:.reverse))] 
		return try viewContext.fetch(request)
	}
	
	func addExercise(category: String, duration: Int, intensity: Int, startTime: Date) throws {
		guard isValidCategory(category) else {
			throw HandleErrors.ExerciseError.invalidCategory
		}
		guard (0...1440).contains(duration) else { // entre 0 et 24h
			throw HandleErrors.ExerciseError.invalidDuration
		}
		guard (0...10).contains(intensity) else {
			throw HandleErrors.ExerciseError.invalidIntensity
		}
		let newExercise = Exercise(context: viewContext)
		newExercise.category = category
		newExercise.duration = Int64(duration)
		newExercise.intensity = Int64(intensity)
		newExercise.startTime = startTime
		try viewContext.save()
	}
	
	func isValidCategory(_ category: String) -> Bool {
		return validExerciseCategories.allCases.contains { $0.rawValue == category }
	}
}
