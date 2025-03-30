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
	@State private var isAddingCategory = false
	@State private var categoryToDelete: Category?
	@State private var showDeleteAlert: Bool = false
	
	func drawCategoriesList(name: String, expense: Bool) -> some View {
		let categories = settingsManager.categories.filter {
			$0.expense == expense
		}
		
		return Section(header: Text(name)) {
			if categories.isEmpty {
				Text("No categories added")
					.foregroundStyle(.gray)
			} else {
				ForEach(categories) { category in
					HStack {
						Image(systemName: category.imageName)
						Text(category.name)
						Button(action: {
							categoryToDelete = category
							showDeleteAlert = true
						}) {
							Image(systemName: "minus.circle")
								.foregroundColor(.red)
						}
					}
				}
				.onDelete { indexSet in
					settingsManager.removeCategory(at: indexSet)
				}
				.alert("Do you really want to delete category \(categoryToDelete?.name ?? "")", isPresented: $showDeleteAlert) {
					Button("Yes", role: .destructive) {
						settingsManager.removeCategory(categoryToDelete!)
					}
					Button("No", role: .cancel) {}
				}
			}
			Button("Add Category") {
				isAddingCategory = true
			}
		}
	}

	var body: some View {
		NavigationView {
			List {
				Section(header: Text("Language")) {
					Picker("Speech Language", selection: $selectedLanguage) {
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
				
				drawCategoriesList(name: "Expense Categories", expense: true)
				drawCategoriesList(name: "Income Categories", expense: false)
				
			}
			.navigationTitle("Settings")
		}
		.onAppear {
			selectedLanguage = settingsManager.getLanguage()
			selectedCurrency = settingsManager.getCurrency()
		}
		.sheet(isPresented: $isAddingCategory) {
			AddCategoryView(settingsManager: settingsManager)
		}
	}
}

#Preview {
    SettingsView()
}
