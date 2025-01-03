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
		var balance1: Double = balance
		return balance
	}
}
