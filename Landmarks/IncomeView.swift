//
//  ExpenseView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 24.12.24..
//

import SwiftUI

struct IncomeView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var income: Double = 0
	@State private var incomeText: String = ""
	@State private var description: String = ""
	@State private var selectedCurrency: Currency = .eur
	@State private var activeCategory: Category? = nil
	
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var categoryManager: CategoryManager
	@EnvironmentObject private var settingsManager: SettingsManager
	
	var body: some View {
		NavigationStack {
			VStack {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 16) {
						Spacer(minLength: 0)
						ForEach(categoryManager.getAll().filter{ $0.expense == false }) { category in
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
				
				let numberFormatter: NumberFormatter = {
						let nf = NumberFormatter()
						nf.locale = Locale.current
						nf.numberStyle = .decimal
						nf.maximumFractionDigits = 1
						return nf
					}()
				
				HStack {
					TextField("Income", text: $incomeText)
						.keyboardType(.decimalPad)
						.onSubmit {
							incomeText = String(income)
						}
						.onChange(of: incomeText) { newValue in
							incomeText = newValue
							income = numberFormatter.number(from: newValue)?.doubleValue ?? 0
						}
						.padding()
					
					Picker("Select an option", selection: $selectedCurrency) {
						ForEach(Currency.allCases) { currency in
							Text(currency.rawValue).tag(currency)
						}
					}
					.onAppear {
						selectedCurrency = settingsManager.currency
					}
				}
				
				TextField("Description", text: $description)
					.padding()
				
				var isActive: Bool = income > 0 && activeCategory != nil
				
				Button("Add") {
					moneyManager.addIncome(
						description: description,
						category: activeCategory!,
						currency: selectedCurrency,
						amount: Double(income)
					)
					dismiss()
				}
				.disabled(!isActive)
				
				
				Spacer()
			}
			.navigationTitle("Add Income")
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
	IncomeView()
}
