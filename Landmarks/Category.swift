//
//  Category.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 24.12.24..
//

import Foundation

struct Category : Identifiable, Equatable {
	init() {
		id = UUID()
		name = ""
		imageName = ""
	}
	
	init(aName: String, anImageName: String) {
		id = UUID()
		name = aName
		imageName = anImageName
	}
	
	var id: UUID
	var name: String
	var imageName: String
}

func ==(left: Category, right: Category) -> Bool {
	return left.id == right.id
}

class CategoryManager: ObservableObject {
	@Published private(set) var categories: [Category] = []
	@Published private(set) var activeCategory: Category = Category()
	
	init() {
		addCategory(name: "Food", imageName: "carrot.fill")
		addCategory(name: "Transport", imageName: "car.fill")
		addCategory(name: "Shopping", imageName: "bag.fill")
		addCategory(name: "Service", imageName: "creditcard.fill")
		addCategory(name: "Restaurant", imageName: "fork.knife")
	}

	func addCategory(name: String, imageName: String) {
		let category = Category(aName: name, anImageName: imageName)
		categories.append(category)
	}
	
	func setActiveCategory(category: Category) {
		activeCategory = category
	}
	
	func getActiveCategory() -> Category {
		return activeCategory
	}

	func getAll() -> [Category] {
		return categories
	}
}
