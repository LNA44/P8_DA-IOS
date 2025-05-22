//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class UserDataViewModel: ObservableObject {
	//MARK: -Public properties
    @Published var firstName: String = ""
    @Published var lastName: String = ""

	//MARK: -Private properties
    private var viewContext: NSManagedObjectContext

	//MARK: -Initialization
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchUserData()
    }

	//MARK: -Methods
    private func fetchUserData() {
		do {
			guard let user = try UserRepository().getUser() else {
				fatalError()
			}
			firstName = "Charlotte"
			lastName = "Corino"
		} catch {
			
		}
        
    }
}
