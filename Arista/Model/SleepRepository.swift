//
//  SleepRepository.swift
//  Arista
//
//  Created by Ordinateur elena on 07/06/2025.
//

import Foundation
import CoreData

protocol SleepRepositoryProtocol {
	func getSleepSessions() throws -> [Sleep]
}

struct SleepRepository: SleepRepositoryProtocol {
	//MARK: -Properties
	let viewContext: NSManagedObjectContext
	
	//MARK: -Initialization
	init(viewContext: NSManagedObjectContext? = nil) {
		self.viewContext = viewContext ?? PersistenceController.viewContext
	}
	
	//MARK: -Methods
	func getSleepSessions() throws -> [Sleep] {
		let request = Sleep.fetchRequest()
		request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Sleep>(\.startDate, order: .reverse))] 
		return try viewContext.fetch(request)
	}
}
