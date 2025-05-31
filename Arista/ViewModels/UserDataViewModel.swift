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
	@Published var errorMessage: String?
	@Published var showAlert: Bool = false

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
			print("fetchUserData called")
			guard let user = try UserRepository(viewContext: viewContext).getUser() else {
				errorMessage = "No user found" // cas ou getUser() renvoie nil car aucun User
				showAlert = true
				firstName = ""
				lastName = ""
				return
			}
			guard let unwrappedFirstName = user.firstName else {
				errorMessage = "User first name is missing"
				showAlert = true
				firstName = ""
				lastName = ""
				return
			}
			guard let unwrappedLastName = user.lastName else {
				errorMessage = "User last name is missing"
				showAlert = true
				firstName = ""
				lastName = ""
				return
			}
			firstName = unwrappedFirstName
			lastName = unwrappedLastName
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
		}
    }
}
