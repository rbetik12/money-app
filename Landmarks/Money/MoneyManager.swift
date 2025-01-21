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
		let expense = MoneyOperation(id: UUID(), date: date, category: category, amount: amount, description: description)
		storage.moneyData.expenses.append(expense)
		storage.moneyData.balance -= amount
		
		objectWillChange.send()
	}
	
	func addIncome(description: String,
					category: Category,
					currency: Currency,
					amount: Double,
					date: Date = Date()) {
		let income = MoneyOperation(id: UUID(), date: date, category: category, amount: amount, description: description)
		storage.moneyData.incomes.append(income)
		storage.moneyData.balance += amount
		
		objectWillChange.send()
	}

	func getAllExpenses() -> [MoneyOperation] {
		return storage.moneyData.expenses
	}
	
	func getAllIncomes() -> [MoneyOperation] {
		return storage.moneyData.incomes
	}
	
	func getIncomeAmount() -> Double {
		return storage.moneyData.incomes.reduce(0) { (result, item) in
			result + item.amount
		}
	}
	
	func getExpenseAmount() -> Double {
		return storage.moneyData.expenses.reduce(0) { (result, item) in
			result + item.amount
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
				result[operation.category, default: 0] += operation.amount
			}
		}
		return storage.moneyData.incomes.reduce(into: [Category: Double]()) { result, operation in
			result[operation.category, default: 0] += operation.amount
		}
	}
}

class MockMoneyManager : MoneyManager {
	override init(storage: MoneyManagerStorage) {
		super.init(storage: storage)
		let categoryManager = CategoryManager()
		
		addExpense(description: "Test", category: categoryManager.getCategoryByName(name: "Food"), currency: .rsd, amount: 100)
		addExpense(description: "Test1", category: categoryManager.getCategoryByName(name: "Transport"), currency: .rsd, amount: 500)
		addExpense(description: "Test1", category: categoryManager.getCategoryByName(name: "Shopping"), currency: .rsd, amount: 50)
	}
}
