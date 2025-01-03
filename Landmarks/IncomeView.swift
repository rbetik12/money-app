//
//  ExpenseView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 24.12.24..
//

import SwiftUI

struct IncomeView: View {
	@State private var income: Int = 0
	@State private var incomeText: String = ""
	@State private var description: String = ""
	@State private var selectedCurrency: Currency = .rsd
	@State private var shouldNavigate: Bool = false
	
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var categoryManager: CategoryManager
	
	var body: some View {
		NavigationStack {
			VStack {
				HStack {
					TextField("Income", text: $incomeText)
						.keyboardType(.numberPad)
						.onChange(of: incomeText) { oldState, newValue in
							incomeText = newValue.filter { $0.isNumber }
							income = Int(incomeText) ?? 0
						}
						.padding()
					
					Picker("Select an option", selection: $selectedCurrency) {
						ForEach(Currency.allCases) { currency in
							Text(currency.rawValue).tag(currency)
						}
					}
				}
				
				TextField("Description", text: $description)
					.padding()
				
				Button("Add") {
					moneyManager.addIncome(
						description: description,
						category: categoryManager.getCategoryByName(name: "Salary"),
						currency: selectedCurrency,
						amount: Double(income)
					)
					shouldNavigate = true // Trigger navigation after adding expense
				}
				.navigationDestination(isPresented: $shouldNavigate) {
					MainScreenView()
				}
				
				
				Spacer()
			}
		}
	}
}

#Preview {
	IncomeView()
}
