//
//  UserRepositoryMock.swift
//  AristaTests
//
//  Created by Ordinateur elena on 20/06/2025.
//

import Foundation
@testable import Arista


final class UserRepositoryMock: UserRepositoryProtocol {
	func getUser() throws -> User? {
		throw NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "Erreur simulée"])
	}
}
