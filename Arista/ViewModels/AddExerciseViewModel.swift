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
			guard let date = convertStringToDate(startTimeString) else {
				return
			}
			startTime = date
		}
	}
    @Published var startTime: Date = Date()
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

	//MARK: -Initialization
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
	
	//MARK: -Methods
    func addExercise() -> Bool {
		do {
			try ExerciseRepository().addExercise(category: category, duration: duration, intensity: intensity, startDate: startTime)
			return true
		} catch let error as HandleErrors.ExerciseError {
				errorMessage = error.errorDescription
				showAlert = true
			return false
		} catch {
			return false
		}
    }
	
	private func convertStringToDate(_ dateString: String) -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter.date(from: dateString)
	}
}
