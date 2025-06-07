//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class AddExerciseViewModel: ObservableObject {
	//MARK: -Public properties
    @Published var category: String = ""
	@Published var startTimeString: String = "" { // car vient d'un textField
		didSet {
			if let combinedDate = convertStringToStartDate(startTimeString) {
				startTime = combinedDate
			} else {
				print("Erreur de conversion de l'heure")
			}
		}
	}
	@Published var startTime: Date = Date() //par défaut
	@Published var durationString: String = "" {
		didSet {
			guard let int = Int(durationString) else {
				return
			}
			duration = int
		}
	}
    @Published var duration: Int = 0
	@Published var intensityString: String = "" {
		didSet {
			guard let int = Int(intensityString) else {
				return
			}
			intensity = int
		}
	}
    @Published var intensity: Int = 0
	@Published var errorMessage: String?
	@Published var showAlert: Bool = false
	var viewContext: NSManagedObjectContext
	let repository: ExerciseRepositoryProtocol

	//MARK: -Initialization
	init(context: NSManagedObjectContext, repository: ExerciseRepositoryProtocol? = nil) {
		self.viewContext = context
		if let repo = repository { //car context doit etre initialisé avant repository
			self.repository = repo
		} else { //si aucun repo passé dans l'init
			self.repository = ExerciseRepository(viewContext: context)
		}
	}
	
	//MARK: -Methods
	func addExercise() -> Bool {
		do {
			try repository.addExercise(category: category, duration: duration, intensity: intensity, startTime: startTime)
			return true
		} catch let error as HandleErrors.ExerciseError {
			errorMessage = error.errorDescription
			showAlert = true
			return false
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
			return false
		}
	}
	
	func convertStringToDate(_ dateString: String) -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter.date(from: dateString)
	}
	
	// Convertit une string "HH:mm" en Date qui combine la date du jour + heure saisie
	func convertStringToStartDate(_ timeString: String) -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		
		guard let timeOnlyDate = formatter.date(from: timeString) else {
			return nil
		}
		
		let calendar = Calendar.current
		let hour = calendar.component(.hour, from: timeOnlyDate)
		let minute = calendar.component(.minute, from: timeOnlyDate)
		
		var components = calendar.dateComponents([.year, .month, .day], from: Date())
		components.hour = hour
		components.minute = minute
		
		return calendar.date(from: components)
	}
}
