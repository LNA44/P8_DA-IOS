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
	var viewContext: NSManagedObjectContext

	//MARK: -Private properties
	private var cancellables = Set<AnyCancellable>()
	private var repository: UserRepositoryProtocol!

	//MARK: -Initialization
	init(context: NSManagedObjectContext, repository: UserRepositoryProtocol = UserRepository(viewContext: PersistenceController.shared.container.viewContext)) {
		self.repository = repository
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
			guard let user = try repository.getUser() else {
				handleError(message: "No user found")
				return
			}
			guard let unwrappedFirstName = user.firstName else {
				handleError(message: "User firstName is missing")
				return
			}
			guard let unwrappedLastName = user.lastName else {
				handleError(message: "User lastName is missing")
				return
			}
			firstName = unwrappedFirstName
			lastName = unwrappedLastName
		} catch {
			errorMessage = "Unknown error happened : \(error.localizedDescription)"
			showAlert = true
		}
    }
	
	private func handleError(message: String) {
		errorMessage = message
		showAlert = true
		firstName = ""
		lastName = ""
	}
}
