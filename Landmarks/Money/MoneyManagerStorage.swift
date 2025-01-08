//
//  MoneyManagerStorage.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 8.1.25..
//

import Foundation

struct MoneyManagerData: Identifiable, Codable {
	var id: UUID = UUID(uuid: uuid_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
	var expenses: [MoneyOperation] = []
	var incomes: [MoneyOperation] = []
	var balance: Double = 0.0
}

class MoneyManagerStorage : ObservableObject {
	@Published var moneyData : MoneyManagerData = MoneyManagerData()
	private let zeroUUID: UUID = UUID(uuid: uuid_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
	
	init() {
		Task {
			do {
				try await load()
			} catch {
				fatalError(error.localizedDescription)
			}
		}
	}
	
	private static func fileURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									in: .userDomainMask,
									appropriateFor: nil,
									create: false)
		.appendingPathComponent("money.data")
	}
	
	func load() async throws {
		let task = Task<MoneyManagerData, Error> {
			let fileURL = try Self.fileURL()
			guard let data = try? Data(contentsOf: fileURL) else {
				return MoneyManagerData()
			}
			let moneyDataDecoded = try JSONDecoder().decode(MoneyManagerData.self, from: data)
			return moneyDataDecoded
		}
		let moneyData = try await task.value
		self.moneyData = moneyData
		
		if self.moneyData.id == zeroUUID {
			self.moneyData.id = UUID()
		}
	}
	
	func save() async throws {
		let task = Task {
			let data = try JSONEncoder().encode(moneyData)
			let outfile = try Self.fileURL()
			try data.write(to: outfile)
		}
		_ = try await task.value
	}
}
