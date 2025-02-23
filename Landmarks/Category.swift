//
//  Category.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 24.12.24..
//

import Foundation
import Charts
import SwiftUI

struct Category : Identifiable, Equatable, Hashable, Codable {
	init() {
		id = UUID()
		name = ""
		imageName = ""
		expense = true
		colorHex = ""
	}
	
	init(id: UUID = UUID(), aName: String, anImageName: String, isExpense: Bool, colorHex: String = "#ea5545") {
		self.id = id
		name = aName
		imageName = anImageName
		expense = isExpense
		self.colorHex = colorHex
	}
	
	var id: UUID
	var name: String
	var imageName: String
	var expense: Bool
	var colorHex: String
}

func ==(left: Category, right: Category) -> Bool {
	return left.id == right.id
}

class CategoryManager: ObservableObject {
	private var settingsManager: SettingsManager
	private var fallbackCategory: Category = Category(aName: "Other", anImageName: "dollarsign.circle", isExpense: true, colorHex: "#ea5545")
	
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
