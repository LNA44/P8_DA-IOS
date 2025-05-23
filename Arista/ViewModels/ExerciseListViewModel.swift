//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class ExerciseListViewModel: ObservableObject {
	//MARK: -Public properties
    @Published var exercises = [Exercise]() //tableau vide
	@Published var errorMessage: String?
	@Published var showAlert: Bool = false
	var viewContext: NSManagedObjectContext

	//MARK: -Initialization
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExercises() //prépare les données avant la création de la vue
    }

	//MARK: -Methods
    private func fetchExercises() {
		do {
			let data = ExerciseRepository(viewContext: viewContext)
			exercises = try data.getExercise()
		} catch let error as NSError {
			errorMessage = "An error occurred while loading your data."
			showAlert = true
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
		}
    }
	
	func reload() {
		fetchExercises()
	}
}
