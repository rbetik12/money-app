//
//  Category.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 24.12.24..
//

import Foundation

struct Category : Identifiable, Equatable, Hashable {
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
	@Published var categories: [Category] = []
	@Published var activeCategory: Category = Category()
	
	init() {
		addCategory(name: "Food", imageName: "carrot.fill")
		addCategory(name: "Transport", imageName: "car.fill")
		addCategory(name: "Shopping", imageName: "bag.fill")
		addCategory(name: "Service", imageName: "creditcard.fill")
		addCategory(name: "Restaurant", imageName: "fork.knife")
		
		addCategory(name: "Salary", imageName: "dollarsign", isExpense: false)
		addCategory(name: "Dividend", imageName: "dollarsign", isExpense: false)
	}

	func addCategory(name: String, imageName: String, isExpense: Bool = true) {
		let category = Category(aName: name, anImageName: imageName, isExpense: isExpense)
		categories.append(category)
	}
	
	func setActiveCategory(category: Category) {
		activeCategory = category
	}
	
	func getActiveCategory() -> Category {
		return activeCategory
	}
	
	func getCategoryByName(name: String) -> Category {
		if let category = categories.first(where: {$0.name == name}) {
			return category
		}
		return categories[0]
	}

	func getAll() -> [Category] {
		return categories
	}
}
