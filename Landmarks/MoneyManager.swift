//
//  MoneyManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 26.12.24..
//

import Foundation

class MoneyManager: ObservableObject {
	@Published private(set) var expenses: [Expense] = []

	func addExpense(description: String, 
					category: Category,
					currency: Currency,
					amount: Double,
					date: Date = Date()) {
		let expense = Expense(id: UUID(), date: date, category: category, amount: amount, description: description)
		expenses.append(expense)
	}

	func getAllExpenses() -> [Expense] {
		return expenses
	}
}
