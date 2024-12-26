//
//  Expense.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 25.12.24..
//

import Foundation

struct Expense: Identifiable {
	let id: UUID
	let date: Date
	let category: Category
	let amount: Double
	let description: String
}
