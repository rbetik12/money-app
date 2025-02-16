//
//  MoneyManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 26.12.24..
//

import Foundation

class MoneyManager: ObservableObject {
	var storage: MoneyManagerStorage
	
	init(storage: MoneyManagerStorage) {
		self.storage = storage
	}

	func addExpense(description: String, 
					category: Category,
					currency: Currency,
					amount: Double,
					date: Date = Date()) {
		let expense = MoneyOperation(id: UUID(), date: date, category: category, amount: amount, description: description, currency: currency, isExpense: true)
		storage.moneyData.expenses.append(expense)
		storage.moneyData.balance -= storage.convert(amount: amount, currency: currency)
		
		objectWillChange.send()
		sendMoneyOperation(operation: expense, isExpense: true)
	}
	
	func addIncome(description: String,
					category: Category,
					currency: Currency,
					amount: Double,
					date: Date = Date()) {
		let income = MoneyOperation(id: UUID(), date: date, category: category, amount: amount, description: description, currency: currency, isExpense: false)
		storage.moneyData.incomes.append(income)
		storage.moneyData.balance += storage.convert(amount: amount, currency: currency)
		
		objectWillChange.send()
		sendMoneyOperation(operation: income, isExpense: false)
	}

	func getAllExpenses() -> [MoneyOperation] {
		let convertedExpenses = storage.moneyData.expenses.map { operation in
			MoneyOperation(id: operation.id,
						   date: operation.date,
						   category: operation.category,
						   amount: storage.convert(amount: operation.amount, currency: operation.currency),
						   description: operation.description,
						   currency: operation.currency,
						   isExpense: true)
		}
		return convertedExpenses
	}
	
	func getAllIncomes() -> [MoneyOperation] {
		let convertedIncomes = storage.moneyData.incomes.map { operation in
			MoneyOperation(id: operation.id,
						   date: operation.date,
						   category: operation.category,
						   amount: storage.convert(amount: operation.amount, currency: operation.currency),
						   description: operation.description,
						   currency: operation.currency,
						   isExpense: false)
		}
		return convertedIncomes
	}
	
	func getIncomeAmount() -> Double {
		return storage.moneyData.incomes.reduce(0) { (result, item) in
			result + storage.convert(amount: item.amount, currency: item.currency)
		}
	}
	
	func getExpenseAmount() -> Double {
		return storage.moneyData.expenses.reduce(0) { (result, item) in
			result + storage.convert(amount: item.amount, currency: item.currency)
		}
	}
	
	func getBalance() -> Double {
		return storage.moneyData.balance
	}
	
	func getOperationsByCategory(category: Category, isExpense: Bool = true) -> [MoneyOperation] {
		if (isExpense) {
			return storage.moneyData.expenses.filter {$0.category == category}
		}
		return storage.moneyData.incomes.filter {$0.category == category}
	}
	
	func getOperationsSumByCategory(isExpense: Bool = true) -> [Category: Double] {
		if (isExpense) {
			return storage.moneyData.expenses.reduce(into: [Category: Double]()) { result, operation in
				result[operation.category, default: 0] += storage.convert(amount: operation.amount, currency: operation.currency)
			}
		}
		return storage.moneyData.incomes.reduce(into: [Category: Double]()) { result, operation in
			result[operation.category, default: 0] += storage.convert(amount: operation.amount, currency: operation.currency)
		}
	}
	
	func sync() {
		let tokenData = KeychainManager.instance.read(forKey: SignInManager.TOKEN_KEYCHAIN_KEY)
		if (tokenData == nil) {
			print("Can't sync money operations, user is not signed in")
			return
		}
		
		let token = String(data: tokenData!, encoding: .utf8)!
		let url = URL(string: "\(URLStorage.getBackendHost())/v1/data/money-operation/all/\(token)")!
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Error get user's money operations: \(error)")
				return
			}
			
			guard let data = data else {
				print("No data received")
				return
			}
			
			do {
				let decoder = JSONDecoder()
				// Custom date decoding strategy
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // Supports microseconds
				dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC handling if needed
				decoder.dateDecodingStrategy = .formatted(dateFormatter)
				let operations = try decoder.decode([MoneyOperation].self, from: data)
				
				DispatchQueue.main.async {
					// Update your UI or state variable here
					print("Successfully decoded money operations: \(operations)")
				}
			} catch {
				print("Failed to decode money operations: \(error)")
			}
			
		}.resume()
	}
	
	private func sendMoneyOperation(operation: MoneyOperation, isExpense: Bool) {
		let tokenData = KeychainManager.instance.read(forKey: SignInManager.TOKEN_KEYCHAIN_KEY)
		if (tokenData == nil) {
			print("Can't send money opration, user is not signed in")
			return
		}
		let token = String(data: tokenData!, encoding: .utf8)
		
		let url = URL(string: "\(URLStorage.getBackendHost())/v1/data/money-operation")!
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONEncoder().encode([
			"token": token,
			"id": operation.id.uuidString,
			"currency": operation.currency.rawValue,
			"amount": String(operation.amount),
			"description": operation.description,
			"category": operation.category.name,
			"isExpense": isExpense ? "true" : "false"
		])
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Error sending money operation: \(error)")
				return
			}
		}.resume()
	}
}

class MockMoneyManager : MoneyManager {
	override init(storage: MoneyManagerStorage) {
		super.init(storage: storage)
		let categoryManager = CategoryManager(settingsManager: SettingsManager())
		
		addExpense(description: "Test", category: categoryManager.getCategoryByName(name: "Food"), currency: .rsd, amount: 100)
		addExpense(description: "Test1", category: categoryManager.getCategoryByName(name: "Transport"), currency: .rsd, amount: 500)
		addExpense(description: "Test1", category: categoryManager.getCategoryByName(name: "Shopping"), currency: .rsd, amount: 50)
	}
}
