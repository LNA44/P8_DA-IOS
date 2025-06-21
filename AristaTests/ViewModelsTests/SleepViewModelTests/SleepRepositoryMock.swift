//
//  SleepRepositoryMock.swift
//  AristaTests
//
//  Created by Ordinateur elena on 21/06/2025.
//

import Foundation
@testable import Arista


final class SleepRepositoryMock: SleepRepositoryProtocol {
	func getSleepSessions() throws -> [Sleep] {
		throw NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "Erreur simulée"])
	}
}
