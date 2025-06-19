//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData
import Combine

class UserDataViewModel: ObservableObject {
	//MARK: -Public properties
    @Published var firstName: String = ""
    @Published var lastName: String = ""
	@Published var errorMessage: String?
	@Published var showAlert: Bool = false

	//MARK: -Private properties
    private var viewContext: NSManagedObjectContext
	private var cancellables = Set<AnyCancellable>()

	//MARK: -Initialization
    init(context: NSManagedObjectContext) {
        self.viewContext = context
		//Notification 1 : erreur d'enregistrement des données en mémoire lors des tests
		NotificationCenter.default.publisher(for: .persistenceSaveError) // evenement créé à chaque notif
			.sink { [weak self] _ in //recoit valeurs du publisher
				if let message = PersistenceController.lastErrorMessage {
					self?.errorMessage  = message
					self?.showAlert = true
				}
			}
			.store(in: &cancellables) //stocke le retour du sink dans cancellables pour garder cet abonnement tant que le VM existe
		//Notification 2 :
		NotificationCenter.default.publisher(for: .coreDataLoadFailed)
			.sink { [weak self] _ in
				if let message = PersistenceController.lastErrorMessage {
					self?.errorMessage  = message
					self?.showAlert = true
				}
			}
			.store(in: &cancellables)
        fetchUserData()
    }

	//MARK: -Methods
    private func fetchUserData() {
		do {
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
