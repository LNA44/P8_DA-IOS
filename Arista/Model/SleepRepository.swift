//
//  SleepRepository.swift
//  Arista
//
//  Created by Ordinateur elena on 07/06/2025.
//

import Foundation
import CoreData

struct SleepRepository {
	//MARK: -Properties
	let viewContext: NSManagedObjectContext
	
	//MARK: -Initialization
	init(viewContext: NSManagedObjectContext) {
		self.viewContext = viewContext
	}
	
	//MARK: -Methods
	func getSleepSessions() throws -> [Sleep] {
		let request = Sleep.fetchRequest()
		request.sortDescriptors = [NSSortDescriptor(SortDescriptor<Sleep>(\.startDate, order: .reverse))] //tri par plus récentes en premier
		return try viewContext.fetch(request)
	}
}
