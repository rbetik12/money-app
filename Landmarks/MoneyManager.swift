//
//  MoneyManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 26.12.24..
//

import Foundation

class MoneyManager: ObservableObject {
	@Published var expenses: [MoneyOperation] = []
	@Published var incomes: [MoneyOperation] = []
	@Published var balance: Double = 0.0

	func addExpense(description: String, 
					category: Category,
					currency: Currency,
					amount: Double,
					date: Date = Date()) {
		let expense = MoneyOperation(id: UUID(), date: date, category: category, amount: amount, description: description)
		expenses.append(expense)
		balance -= amount
	}
	
	func addIncome(description: String,
					category: Category,
					currency: Currency,
					amount: Double,
					date: Date = Date()) {
		let income = MoneyOperation(id: UUID(), date: date, category: category, amount: amount, description: description)
		incomes.append(income)
		balance += amount
	}

	func getAllExpenses() -> [MoneyOperation] {
		return expenses
	}
	
	func getBalance() -> Double {
		return balance
	}
	
	func getOperationsByCategory(category: Category, isExpense: Bool = true) -> [MoneyOperation] {
		if (isExpense) {
			return expenses.filter {$0.category == category}
		}
		return incomes.filter {$0.category == category}
	}
	
	func getOperationsSumByCategory(isExpense: Bool = true) -> [Category: Double] {
		if (isExpense) {
			return expenses.reduce(into: [Category: Double]()) { result, operation in
				result[operation.category, default: 0] += operation.amount
			}
		}
		return incomes.reduce(into: [Category: Double]()) { result, operation in
			result[operation.category, default: 0] += operation.amount
		}
	}
}

class MockMoneyManager : MoneyManager {
	override init() {
		super.init()
		let categoryManager = CategoryManager()
		
		addExpense(description: "Test", category: categoryManager.getCategoryByName(name: "Food"), currency: .rsd, amount: 100)
		addExpense(description: "Test1", category: categoryManager.getCategoryByName(name: "Transport"), currency: .rsd, amount: 500)
		addExpense(description: "Test1", category: categoryManager.getCategoryByName(name: "Shopping"), currency: .rsd, amount: 50)
	}
}
