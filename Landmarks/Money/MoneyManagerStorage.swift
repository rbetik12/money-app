//
//  MoneyManagerStorage.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 8.1.25..
//

import Foundation

struct ExchangeRateResponse: Codable {
	let result: String
	let documentation: String
	let termsOfUse: String
	let timeLastUpdateUnix: Int
	let timeLastUpdateUTC: String
	let timeNextUpdateUnix: Int
	let timeNextUpdateUTC: String
	let baseCode: String
	let conversionRates: [String: Double]
	
	enum CodingKeys: String, CodingKey {
		case result
		case documentation
		case termsOfUse = "terms_of_use"
		case timeLastUpdateUnix = "time_last_update_unix"
		case timeLastUpdateUTC = "time_last_update_utc"
		case timeNextUpdateUnix = "time_next_update_unix"
		case timeNextUpdateUTC = "time_next_update_utc"
		case baseCode = "base_code"
		case conversionRates = "conversion_rates"
	}
}

struct MoneyManagerData: Identifiable, Codable {
	var id: UUID = UUID(uuid: uuid_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
	var expenses: [MoneyOperation] = []
	var incomes: [MoneyOperation] = []
	var balance: Double = 0.0
	var mainCurrency: Currency = .eur
	var currencyRateUpdateTime: Int = 0
	var convertionRates = [Currency: Double]()
}

class MoneyManagerStorage : ObservableObject {
	@Published var moneyData : MoneyManagerData = MoneyManagerData()
	private let zeroUUID: UUID = UUID(uuid: uuid_t(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
	
	init() {
		Task {
			do {
				try await load()
				await loadConvertionRates()
			} catch {
				fatalError(error.localizedDescription)
			}
		}
	}
	
	func convert(amount: Double, currency: Currency) -> Double {
		return amount / moneyData.convertionRates[currency]!
	}
	
	private static func fileURL() throws -> URL {
		try FileManager.default.url(for: .documentDirectory,
									in: .userDomainMask,
									appropriateFor: nil,
									create: false)
		.appendingPathComponent("money.data")
	}
	
	private func loadConvertionRates() async {
		if (moneyData.currencyRateUpdateTime > Int(Date().timeIntervalSince1970)) {
			return
		}
		
		guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "CurrencyApiKey") as? String else {
			print("CurrencyApiKey not found")
			return
		}
		
		guard let url = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/EUR") else {
			return
		}
		
		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			let exchangeRatesResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
			self.moneyData.currencyRateUpdateTime = exchangeRatesResponse.timeNextUpdateUnix
			
			for currency in Currency.allCases {
				self.moneyData.convertionRates[currency] = exchangeRatesResponse.conversionRates[currency.rawValue.uppercased()]
			}
		} catch {
			print("Can't parse rates json: \(error)")
		}
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
