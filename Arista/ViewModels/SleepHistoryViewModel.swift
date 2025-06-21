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
	init(context: NSManagedObjectContext, repository: SleepRepositoryProtocol = SleepRepository(viewContext: PersistenceController.shared.container.viewContext)) {
        self.viewContext = context
		self.repository = repository
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
