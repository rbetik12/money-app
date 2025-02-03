//
//  SettingsView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 2.2.25..
//

import SwiftUI

struct SettingsView: View {
	@EnvironmentObject private var settingsManager: SettingsManager
	
	@State private var selectedLanguage = "en-US"
	@State private var selectedCurrency: Currency = .eur

	var body: some View {
		NavigationView {
			List {
				Section(header: Text("Language")) {
					Picker("Select Language", selection: $selectedLanguage) {
						ForEach(Array(settingsManager.getSupportedLanguagesList().keys), id: \.self) { code in
							Text(settingsManager.getSupportedLanguagesList()[code]!).tag(code)
						}
					}
					.pickerStyle(MenuPickerStyle())
					.onChange(of: selectedLanguage) { newValue in
						settingsManager.setLanguage(language: newValue)
					}
				}

				Section(header: Text("Main Currency")) {
					Picker("Select Currency", selection: $selectedCurrency) {
						ForEach(Currency.allCases) { currency in
							Text(currency.rawValue).tag(currency)
						}
					}
					.pickerStyle(MenuPickerStyle())
					.onChange(of: selectedCurrency) { newValue in
						settingsManager.setCurrency(currency: newValue)
					}
				}
			}
			.navigationTitle("Settings")
		}
		.onAppear() {
			selectedLanguage = settingsManager.getLanguage()
			selectedCurrency = settingsManager.getCurrency()
		}
	}
}

#Preview {
    SettingsView()
}
