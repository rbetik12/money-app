//
//  MoneyManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 26.12.24..
//

import Foundation
import OrderedCollections

class MoneyManager: ObservableObject {
	var storage: MoneyManagerStorage
	var categoryManager: CategoryManager
	
	init(storage: MoneyManagerStorage, categoryManager: CategoryManager) {
		self.storage = storage
		self.categoryManager = categoryManager
	}

	func addExpense(description: String, 
					category: Category,
					currency: Currency,
					amount: Double,
					date: Date = Date()) {
		let expense = MoneyOperation(id: UUID(), date: date, category: category, amount: amount, description: description, currency: currency, isExpense: true)
		addExpenseInternal(op: expense)
		sendMoneyOperation(operation: expense, isExpense: true)
	}
	
	func addIncome(description: String,
					category: Category,
					currency: Currency,
					amount: Double,
					date: Date = Date()) {
		let income = MoneyOperation(id: UUID(), date: date, category: category, amount: amount, description: description, currency: currency, isExpense: false)
		addIncomeInternal(op: income)
		sendMoneyOperation(operation: income, isExpense: false)
	}
	
	func deleteOp(operation: MoneyOperation) {
		if operation.isExpense {
			storage.moneyData.expenses.removeAll { $0.id == operation.id }
		}
		else {
			storage.moneyData.incomes.removeAll { $0.id == operation.id }
		}
		
		objectWillChange.send()
		sendDeleteOperation(operation: operation)
	}
	
	func updateOp(operation: MoneyOperation) {
		if operation.isExpense {
			guard let storedOpIdx = storage.moneyData.expenses.firstIndex(where: { $0.id == operation.id }) else {
				return
			}
			
			storage.moneyData.expenses[storedOpIdx].amount = operation.amount
			storage.moneyData.expenses[storedOpIdx].currency = operation.currency
			storage.moneyData.expenses[storedOpIdx].description = operation.description
			storage.moneyData.expenses[storedOpIdx].category = operation.category
			storage.moneyData.expenses[storedOpIdx].date = operation.date
			
			sendMoneyOperation(operation: storage.moneyData.expenses[storedOpIdx], isExpense: true, update: true)
		} else {
			guard let storedOpIdx = storage.moneyData.incomes.firstIndex(where: { $0.id == operation.id }) else {
				return
			}
			
			storage.moneyData.incomes[storedOpIdx].amount = operation.amount
			storage.moneyData.incomes[storedOpIdx].currency = operation.currency
			storage.moneyData.incomes[storedOpIdx].description = operation.description
			storage.moneyData.incomes[storedOpIdx].category = operation.category
			storage.moneyData.incomes[storedOpIdx].date = operation.date
			
			sendMoneyOperation(operation: storage.moneyData.incomes[storedOpIdx], isExpense: false, update: true)
		}
		
		objectWillChange.send()
	}
	
	private func addExpenseInternal(op: MoneyOperation) {
		storage.moneyData.expenses.append(op)
		objectWillChange.send()
	}
	
	private func addIncomeInternal(op: MoneyOperation) {
		storage.moneyData.incomes.append(op)
		objectWillChange.send()
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
	
	func getIncomeAmount(month: Int? = nil, year: Int? = nil) -> Double {
		let filteredIncomes: [MoneyOperation]
		
		if let month = month, let year = year {
			filteredIncomes = storage.moneyData.incomes.filter { operation in
				let calendar = Calendar.current
				let operationMonth = calendar.component(.month, from: operation.date)
				let operationYear = calendar.component(.year, from: operation.date)
				return operationMonth == month && operationYear == year
			}
		} else {
			filteredIncomes = storage.moneyData.incomes
		}
		
		return filteredIncomes.reduce(0) { (result, item) in
			result + storage.convert(amount: item.amount, currency: item.currency)
		}
	}

	func getExpenseAmount(month: Int? = nil, year: Int? = nil) -> Double {
		let filteredExpenses: [MoneyOperation]
		
		if let month = month, let year = year {
			filteredExpenses = storage.moneyData.expenses.filter { operation in
				let calendar = Calendar.current
				let operationMonth = calendar.component(.month, from: operation.date)
				let operationYear = calendar.component(.year, from: operation.date)
				return operationMonth == month && operationYear == year
			}
		} else {
			filteredExpenses = storage.moneyData.expenses
		}
		
		return filteredExpenses.reduce(0) { (result, item) in
			result + storage.convert(amount: item.amount, currency: item.currency)
		}
	}

	func getBalance(month: Int? = nil, year: Int? = nil) -> Double {
		return getIncomeAmount(month: month, year: year) - getExpenseAmount(month: month, year: year)
	}
	
	func getOperationsByCategory(category: Category, isExpense: Bool = true, month: Int, year: Int) -> [MoneyOperation] {
		let calendar = Calendar.current
		let operations = isExpense ? storage.moneyData.expenses : storage.moneyData.incomes
		return operations.filter { $0.category == category && calendar.component(.month, from: $0.date) == month && calendar.component(.year, from: $0.date) == year }
	}
	
	func getOperationsSumByCategory(isExpense: Bool = true, month: Int, year: Int) -> OrderedDictionary<Category, Double> {
		let calendar = Calendar.current

		let operations = isExpense ? storage.moneyData.expenses : storage.moneyData.incomes

		let categorySums = operations.reduce(into: [Category: Double]()) { result, operation in
			let operationDate = operation.date
			let operationMonth = calendar.component(.month, from: operationDate)
			let operationYear = calendar.component(.year, from: operationDate)

			if operationMonth == month && operationYear == year {
				result[operation.category, default: 0] += storage.convert(amount: operation.amount, currency: operation.currency)
			}
		}

		// Sort by value in descending order and return as OrderedDictionary
		return OrderedDictionary(uniqueKeysWithValues: categorySums.sorted { $0.value > $1.value })
	}
	
	func sendOperationsText(text: String, onResult: @escaping(_ data: [MoneyOperation]) -> Void) {
		let tokenData = KeychainManager.instance.read(forKey: SignInManager.TOKEN_KEYCHAIN_KEY)
		if (tokenData == nil) {
			print("Can't send money operations, user is not signed in")
			return
		}
		let token = String(data: tokenData!, encoding: .utf8)!
		
		struct OperationsRequest: Codable {
			let token: String
			let text: String
			let expenseCategories: [String]
			let incomeCategories: [String]
		}
		
		let body = OperationsRequest(token: token, text: text, expenseCategories: categoryManager.getAll(expense: true).map {$0.name}, incomeCategories: categoryManager.getAll(expense: false).map {$0.name})
		let url = URL(string: "\(URLStorage.getBackendHost())/v1/data/money-operation/ai")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONEncoder().encode(body)
		
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
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
				dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
				decoder.dateDecodingStrategy = .formatted(dateFormatter)
				let operations = try decoder.decode([MoneyOperationInternal].self, from: data)
				
				var parsedOperations: [MoneyOperation] = []
				
				for operation in operations {
					if operation.isExpense && !self.storage.moneyData.expenses.contains(where: { $0.id == operation.id }) {
						let op = MoneyOperation(id: operation.id,
												date: operation.date,
												category: self.categoryManager.getCategoryByName(name: operation.category),
												amount: operation.amount,
												description: operation.description,
												currency: Currency(rawValue: operation.currency.uppercased())!,
												isExpense: true)
						parsedOperations.append(op)
						DispatchQueue.main.async {
							self.addExpenseInternal(op: op)
						}
					} else if !operation.isExpense && !self.storage.moneyData.incomes.contains(where: { $0.id == operation.id }) {
						let op = MoneyOperation(id: operation.id,
												date: operation.date,
												category: self.categoryManager.getCategoryByName(name: operation.category),
												amount: operation.amount,
												description: operation.description,
												currency: Currency(rawValue: operation.currency.uppercased())!,
												isExpense: true)
						parsedOperations.append(op)
						DispatchQueue.main.async {
							self.addIncomeInternal(op: op)
						}
					}
				}
				
				onResult(parsedOperations)
			} catch {
				print("Failed to decode money operations: \(error)")
			}
			
		}.resume()
	}
	
	func sync() {
		if (storage.moneyData.convertionRates.isEmpty) {
			return
		}
		
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
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
				dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
				decoder.dateDecodingStrategy = .formatted(dateFormatter)
				let operations = try decoder.decode([MoneyOperationInternal].self, from: data)
				
				for operation in operations {
					if operation.isExpense && !self.storage.moneyData.expenses.contains(where: { $0.id == operation.id }) {
						DispatchQueue.main.async {
							let op = MoneyOperation(id: operation.id,
													date: operation.date,
													category: self.categoryManager.getCategoryByName(name: operation.category),
													amount: operation.amount,
													description: operation.description,
													currency: Currency(rawValue: operation.currency.uppercased())!,
													isExpense: true)
							self.addExpenseInternal(op: op)
						}
					} else if !operation.isExpense && !self.storage.moneyData.incomes.contains(where: { $0.id == operation.id }) {
						DispatchQueue.main.async {
							let op = MoneyOperation(id: operation.id,
													date: operation.date,
													category: self.categoryManager.getCategoryByName(name: operation.category),
													amount: operation.amount,
													description: operation.description,
													currency: Currency(rawValue: operation.currency.uppercased())!,
													isExpense: false)
							self.addIncomeInternal(op: op)
						}
					}
				}
				
				for expense in self.storage.moneyData.expenses {
					if !operations.contains(where: { $0.id == expense.id }) {
						self.sendMoneyOperation(operation: expense, isExpense: true)
					}
				}
				
				for income in self.storage.moneyData.incomes {
					if !operations.contains(where: { $0.id == income.id }) {
						self.sendMoneyOperation(operation: income, isExpense: false)
					}
				}
			} catch {
				print("Failed to decode money operations: \(error)")
			}
			
		}.resume()
	}
	
	private func sendMoneyOperation(operation: MoneyOperation, isExpense: Bool, update: Bool = false) {
		let tokenData = KeychainManager.instance.read(forKey: SignInManager.TOKEN_KEYCHAIN_KEY)
		if (tokenData == nil) {
			print("Can't send money opration, user is not signed in")
			return
		}
		let token = String(data: tokenData!, encoding: .utf8)
		
		let url = URL(string: "\(URLStorage.getBackendHost())/v1/data/money-operation")!
		
		var request = URLRequest(url: url)
		request.httpMethod = update ? "PUT" : "POST"
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
	
	private func sendDeleteOperation(operation: MoneyOperation) {
		let tokenData = KeychainManager.instance.read(forKey: SignInManager.TOKEN_KEYCHAIN_KEY)
		if (tokenData == nil) {
			print("Can't send money opration, user is not signed in")
			return
		}
		let token = String(data: tokenData!, encoding: .utf8)
		
		let url = URL(string: "\(URLStorage.getBackendHost())/v1/data/money-operation/\(operation.id.uuidString)/\(token!)")!
		var request = URLRequest(url: url)
		request.httpMethod = "DELETE"
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Error sending money operation: \(error)")
				return
			}
		}.resume()
	}
}
