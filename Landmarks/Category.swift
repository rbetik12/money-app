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
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// Decode ID (provide a default if missing)
		id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
		
		// Decode other properties
		name = try container.decode(String.self, forKey: .name)
		imageName = try container.decode(String.self, forKey: .imageName)
		expense = try container.decode(Bool.self, forKey: .expense)
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
	
	init(settingsManager: SettingsManager) {
		self.settingsManager = settingsManager
	}
	
	func getCategoryByName(name: String) -> Category {
		if let category = settingsManager.getCategories().first(where: {$0.name == name}) {
			return category
		}
		return settingsManager.getCategories().first!
	}

	func getAll() -> [Category] {
		return settingsManager.getCategories()
	}
}
