//
//  Expense.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 25.12.24..
//

import Foundation

struct MoneyOperation: Identifiable, Codable, Hashable {
	let id: UUID
	var date: Date
	var category: Category
	var amount: Double
	var description: String
	var currency: Currency
	var isExpense: Bool
}

struct MoneyOperationInternal: Identifiable, Codable {
	let id: UUID
	let date: Date
	let category: String
	let amount: Double
	let description: String
	let currency: String
	let isExpense: Bool
}

