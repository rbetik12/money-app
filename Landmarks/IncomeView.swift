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
	@State private var activeCategory: Category? = nil
	
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var categoryManager: CategoryManager
	
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
				
				HStack {
					TextField("Income", text: $incomeText)
						.keyboardType(.numberPad)
						.onChange(of: incomeText) { newValue in
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
						category: activeCategory ?? categoryManager.getAll().filter{ $0.expense == false }.first!,
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
