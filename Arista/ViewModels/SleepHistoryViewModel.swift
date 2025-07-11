//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

class SleepHistoryViewModel: ObservableObject {
	//MARK: -Public properties
	@Published var sleepSessions = [Sleep]()
	@Published var errorMessage: String?
	@Published var showAlert: Bool = false
	
	//MARK: -Private properties
	private var repository: SleepRepositoryProtocol!
	
	//MARK: -Initialization
	init(repository: SleepRepositoryProtocol? = nil) {
		if let repo = repository {
			self.repository = repo
		} else { //si aucun repo passé dans l'init
			self.repository = SleepRepository()
		}
		fetchSleepSessions()
	}
	
	//MARK: -Methods
	private func fetchSleepSessions() {
		do {
			sleepSessions = try repository.getSleepSessions()
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
		}
	}
}
