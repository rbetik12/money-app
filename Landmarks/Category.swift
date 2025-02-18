//
//  Category.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 24.12.24..
//

import Foundation

struct Category : Identifiable, Equatable, Hashable, Codable {
	init() {
		id = UUID()
		name = ""
		imageName = ""
		expense = true
	}
	
	init(aName: String, anImageName: String, isExpense: Bool) {
		id = UUID()
		name = aName
		imageName = anImageName
		expense = isExpense
	}
	
	var id: UUID
	var name: String
	var imageName: String
	var expense: Bool
}

func ==(left: Category, right: Category) -> Bool {
	return left.id == right.id
}

class CategoryManager: ObservableObject {
	private var settingsManager: SettingsManager
	private var fallbackCategory: Category = Category(aName: "Other", anImageName: "dollarsign.circle", isExpense: true)
	
	init(settingsManager: SettingsManager) {
		self.settingsManager = settingsManager
	}
	
	func getCategoryByName(name: String) -> Category {
		if let category = settingsManager.getCategories().first(where: {$0.name == name}) {
			return category
		}
		return fallbackCategory
	}

	func getAll() -> [Category] {
		return settingsManager.getCategories()
	}
	
	func getAll(expense: Bool) -> [Category] {
		return settingsManager.getCategories().filter({ $0.expense })
	}
}
