//
//  SettingsManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 2.2.25..
//

import Foundation
import SwiftUI

class SettingsManager : ObservableObject {
	@AppStorage("language") var language: String = "en-US"
	@AppStorage("currency") var currency: Currency = .eur
	
	@Published private(set) var categories: [Category] = []
	@Published private var categoryUUIDToColor: [UUID: String] = [:]
	
	private let categoriesKey = "categories"
	private let categoriesColorsKey = "categoriesColors"
	private let supportedLanguages: [String: String] = [
		"en-US": "English (US)",
		"ru-RU": "Russian"
	]
	private let categoryColorsList = ["#ea5545", "#f46a9b", "#ef9b20", "#edbf33", "#ede15b", "#bdcf32", "#87bc45", "#27aeef", "#b33dc6"]
	
	init() {
		loadCategories()
		
		// first launch
		if (categories.isEmpty) {
			var category = Category(aName: "Food", anImageName: "carrot.fill", isExpense: true)
			category.colorHex = getCategoryColor(uuid: category.id)
			addCategory(category)
			
			category = Category(aName: "Transport", anImageName: "car.fill", isExpense: true)
			category.colorHex = getCategoryColor(uuid: category.id)
			addCategory(category)
			
			category = Category(aName: "Shopping", anImageName: "bag.fill", isExpense: true)
			category.colorHex = getCategoryColor(uuid: category.id)
			addCategory(category)
			
			category = Category(aName: "Service", anImageName: "creditcard.fill", isExpense: true)
			category.colorHex = getCategoryColor(uuid: category.id)
			addCategory(category)
			
			category = Category(aName: "Restaurant", anImageName: "fork.knife", isExpense: true)
			category.colorHex = getCategoryColor(uuid: category.id)
			addCategory(category)
			
			category = Category(aName: "Salary", anImageName: "dollarsign", isExpense: false)
			category.colorHex = getCategoryColor(uuid: category.id)
			addCategory(category)
			
			category = Category(aName: "Dividend", anImageName: "dollarsign", isExpense: false)
			category.colorHex = getCategoryColor(uuid: category.id)
			addCategory(category)
		}
	}
	
	func getCategoryColor(uuid: UUID) -> String {
		if categoryUUIDToColor.contains(where: { $0.key == uuid }) {
			return categoryUUIDToColor[uuid] ?? categoryColorsList[0]
		}
		
		for (index, color) in categoryColorsList.enumerated() {
			if !categoryUUIDToColor.contains(where: { $0.value == color }) {
				categoryUUIDToColor[uuid] = color
				return color
			}
		}
		
		return categoryColorsList[0]
	}
	
	func languageToHumanReadable(language: String) -> String {
		return getSupportedLanguagesList()[language] ?? "English (US)"
	}

	func getSupportedLanguagesList() -> [String: String] {
		return supportedLanguages
	}
	
	func getLocale() -> Locale {
		return Locale(identifier: language)
	}
	
	func getLanguage() -> String {
		return language
	}
	
	func setLanguage(language: String) {
		self.language = language
	}
	
	func setCurrency(currency: Currency) {
		self.currency = currency
		
		objectWillChange.send()
	}
	
	func getCurrency() -> Currency {
		return currency
	}
	
	func loadCategories() {
		if let data = UserDefaults.standard.data(forKey: categoriesKey) {
			if let decoded = try? JSONDecoder().decode([Category].self, from: data) {
				self.categories = decoded
			}
		}
		
		for category in categories {
			categoryUUIDToColor[category.id] = category.colorHex
		}
	}
	
	func saveCategories() {
		if let encoded = try? JSONEncoder().encode(categories) {
			UserDefaults.standard.set(encoded, forKey: categoriesKey)
		}
	}
	
	func getCategories() -> [Category] {
		return categories
	}
	
	func addCategory(_ category: Category) {
		categories.append(category)
		saveCategories()
	}
	
	func removeCategory(at offsets: IndexSet) {
		categories.remove(atOffsets: offsets)
		saveCategories()
	}
	
	func removeCategory(_ category: Category) {
		categories.removeAll { $0.id == category.id }
		saveCategories()
	}
}
