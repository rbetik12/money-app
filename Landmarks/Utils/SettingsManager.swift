//
//  SettingsManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 2.2.25..
//

import Foundation
import SwiftUI

class SettingsManager : ObservableObject {
	@AppStorage("language") private var language: String = "en-US"
	@AppStorage("currency") private var currency: Currency = .eur
	
	@Published private(set) var categories: [Category] = []
	
	private let categoriesKey = "categories"
	private let supportedLanguages: [String: String] = [
		"en-US": "English (US)",
		"ru-RU": "Russian"
	]
	
	init() {
		loadCategories()
		
		// first launch
		if (categories.isEmpty) {
			addCategory(Category(aName: "Food", anImageName: "carrot.fill", isExpense: true))
			addCategory(Category(aName: "Transport", anImageName: "car.fill", isExpense: true))
			addCategory(Category(aName: "Shopping", anImageName: "bag.fill", isExpense: true))
			addCategory(Category(aName: "Service", anImageName: "creditcard.fill", isExpense: true))
			addCategory(Category(aName: "Restaurant", anImageName: "fork.knife", isExpense: true))
			addCategory(Category(aName: "Salary", anImageName: "dollarsign", isExpense: false))
			addCategory(Category(aName: "Dividend", anImageName: "dollarsign", isExpense: false))
		}
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
