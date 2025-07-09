//
//  UserRepositoryMock.swift
//  AristaTests
//
//  Created by Ordinateur elena on 20/06/2025.
//

import Foundation
import CoreData
@testable import Arista

enum MockScenarioUserRepository {
	case noFirstName
	case noLastName
	case NSError
}

struct UserRepositoryMock: UserRepositoryProtocol {
	let scenario: MockScenarioUserRepository
	
	func getUser() throws -> User? {
		switch scenario {
		case .noFirstName:
			let user = User(context: PersistenceController().container.viewContext)
			user.lastName = "Durand"
			return user
		case .noLastName:
			let user = User(context: PersistenceController().container.viewContext)
			user.firstName = "Patrick"
			return user
		case .NSError:
			throw NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "Erreur simulée"])
		}
	}
}
