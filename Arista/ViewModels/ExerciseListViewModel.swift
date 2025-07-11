//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

class ExerciseListViewModel: ObservableObject {
	//MARK: -Public properties
	@Published var exercises = [Exercise]()
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
		fetchExercises()
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
