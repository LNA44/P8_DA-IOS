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
    
	//MARK: -Initialization
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchSleepSessions()
    }
    
	//MARK: -Methods
	func fetchSleepSessions() {
		do {
			print("fetchSleepSessions appelée")
			let data = SleepRepository(viewContext: viewContext)
			sleepSessions = try data.getSleepSessions()
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
		}
    }
}
