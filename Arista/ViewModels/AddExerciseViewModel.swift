//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

class AddExerciseViewModel: ObservableObject {
	//MARK: -Public properties
	@Published var category: String = ""
	@Published var startTimeString: String = "" { // car vient d'un textField
		didSet {
			if let combinedDate = convertStringToStartDate(startTimeString) {
				startTime = combinedDate
			} else {
				startTime = defaultStartDate()
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
	
	//MARK: -Private properties
	private var repository: ExerciseRepositoryProtocol!
	
	//MARK: -Initialization
	init(repository: ExerciseRepositoryProtocol? = nil) {
		if let repo = repository {
			self.repository = repo
		} else { 
			self.repository = ExerciseRepository()
		}
	}
	
	//MARK: -Methods
	func addExercise(){
		do {
			try repository.addExercise(category: category, duration: duration, intensity: intensity, startTime: startTime)
		} catch let error as HandleErrors.ExerciseError {
			errorMessage = error.errorDescription
			showAlert = true
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
		}
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
	
	private func defaultStartDate() -> Date {
		var components = DateComponents()
		components.year = 2000
		components.month = 1
		components.day = 1
		components.hour = 0
		components.minute = 0
		return Calendar.current.date(from: components)!
	}
}
