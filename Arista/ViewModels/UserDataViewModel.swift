//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import Combine

class UserDataViewModel: ObservableObject {
	//MARK: -Public properties
	@Published var firstName: String = ""
	@Published var lastName: String = ""
	@Published var errorMessage: String?
	@Published var showAlert: Bool = false
	
	//MARK: -Private properties
	private var cancellables = Set<AnyCancellable>()
	private var repository: UserRepositoryProtocol!
	
	//MARK: -Initialization
	init(repository: UserRepositoryProtocol? = nil) {
		if let repo = repository {
			self.repository = repo
		} else {
			self.repository = UserRepository()
		}
		
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
