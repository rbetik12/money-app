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
	
	private let supportedLanguages: [String: String] = [
		"en-US": "English (US)",
		"ru-RU": "Russian"
	]
	
	func getSupportedLanguagesList() -> [String: String] {
		return supportedLanguages
	}
	
	func getLocale() -> Locale {
		return Locale(identifier: language)
	}
	
	func getLanguage() -> String {
		return supportedLanguages.first(where: { $0.key == language })?.value ?? "Unknown"
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
}
