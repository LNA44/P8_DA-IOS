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
	
	//MARK: -Private properties
	private var repository: ExerciseRepositoryProtocol!
	
	//MARK: -Initialization
	init(context: NSManagedObjectContext, repository: ExerciseRepositoryProtocol? = nil) {
		self.viewContext = context
		if let repo = repository {
			self.repository = repo
		} else {
			self.repository = ExerciseRepository(viewContext: context)
		}
		fetchExercises() //prépare les données avant la création de la vue
	}
	
	//MARK: -Methods
	private func fetchExercises() {
		do {
			exercises = try repository.getExercise()
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
		}
	}
	
	func reload() {
		fetchExercises()
	}
}
