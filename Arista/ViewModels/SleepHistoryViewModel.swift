//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class SleepHistoryViewModel: ObservableObject {
	//MARK: -Public properties
	@Published var sleepSessions = [Sleep]()
	@Published var errorMessage: String?
	@Published var showAlert: Bool = false
	
	//MARK: -Private properties
	private var viewContext: NSManagedObjectContext
	private var repository: SleepRepositoryProtocol!
	
	//MARK: -Initialization
	init(context: NSManagedObjectContext, repository: SleepRepositoryProtocol? = nil) { 
		self.viewContext = context
		if let repo = repository {
			self.repository = repo
		} else { //si aucun repo passé dans l'init
			self.repository = SleepRepository(viewContext: context)
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
