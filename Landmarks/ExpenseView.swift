//
//  ExpenseView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 24.12.24..
//

import SwiftUI

struct ExpenseView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var expense: Int = 0
	@State private var expenseText: String = ""
	@State private var description: String = ""
	@State private var selectedCurrency: Currency = .eur
	@State private var activeCategory: Category? = nil
	
	@EnvironmentObject var categoryManager: CategoryManager
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject private var settingsManager: SettingsManager
	
	var body: some View {
		NavigationStack {
			VStack {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 16) {
						Spacer(minLength: 0)
						ForEach(categoryManager.getAll().filter{ $0.expense == true }) { category in
							VStack {
								Image(systemName: category.imageName)
									.resizable()
									.scaledToFit()
									.scaleEffect(0.7)
									.frame(width: 60, height: 60)
								
								Text(category.name)
									.font(.caption)
									.foregroundColor(activeCategory == category ? Color.blue : Color.gray)
							}
							.onTapGesture {
								activeCategory = category
							}
						}
						Spacer(minLength: 0)
					}
					.padding()
				}
				.frame(maxWidth: .infinity, alignment: .center)
				.background(Color.gray.opacity(0.1))
				.onAppear {
					activeCategory = categoryManager.getAll().first
				}
				
				HStack {
					TextField("Expense", text: $expenseText)
						.keyboardType(.numberPad)
						.onSubmit {
							expenseText = String(expense)
						}
						.onChange(of: expenseText) { newValue in
							expenseText = newValue.filter { $0.isNumber }
							expense = Int(expenseText) ?? 0
						}
						.padding()
					
					selectedCurrency = settingsManager.currency
					
					Picker("Select an option", selection: $selectedCurrency) {
						ForEach(Currency.allCases) { currency in
							Text(currency.rawValue).tag(currency)
						}
					}
				}
				
				TextField("Description", text: $description)
					.padding()
				
				var isActive = activeCategory != nil && expense > 0
				
				Button("Add") {
					moneyManager.addExpense(
						description: description,
						category: activeCategory!,
						currency: selectedCurrency,
						amount: Double(expense)
					)
					dismiss()

				}
				.disabled(!isActive)
				
				
				Spacer()
			}
			.navigationTitle("Add Expense")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Close") {
						dismiss()
					}
				}
			}
		}
	}
}

#Preview {
	ExpenseView()
}
