//
//  MoneyManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 26.12.24..
//

import Foundation

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
	
	private func addExpenseInternal(op: MoneyOperation) {
		storage.moneyData.expenses.append(op)
		storage.moneyData.balance -= storage.convert(amount: op.amount, currency: op.currency)
		
		objectWillChange.send()
	}
	
	private func addIncomeInternal(op: MoneyOperation) {
		storage.moneyData.incomes.append(op)
		storage.moneyData.balance += storage.convert(amount: op.amount, currency: op.currency)
		
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
