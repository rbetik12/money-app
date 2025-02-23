//
//  MoneyOperationEditView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 23.2.25..
//

import SwiftUI

struct MoneyOperationEditView: View {
	@State var moneyOperation: MoneyOperation
	@EnvironmentObject var categoryManager: CategoryManager
	@EnvironmentObject var moneyManager: MoneyManager
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		Form {
			Section(header: Text("Details")) {
				DatePicker("Date", selection: $moneyOperation.date, displayedComponents: .date)
				
				Picker("Category", selection: $moneyOperation.category) {
					ForEach(categoryManager.getAll()) { category in
						Text(category.name).tag(category)
					}
				}
				
				TextField("Description", text: $moneyOperation.description)
				
				Picker("Currency", selection: $moneyOperation.currency) {
					ForEach(Currency.allCases) { currency in
						Text(currency.rawValue).tag(currency)
					}
				}
				
				Toggle("Expense", isOn: $moneyOperation.isExpense)
			}
			
			Section(header: Text("Amount")) {
				TextField("Amount", value: $moneyOperation.amount, formatter: NumberFormatter())
					.keyboardType(.decimalPad)
			}
		}
		.navigationTitle("Edit Money Operation")
		.navigationBarItems(trailing: Button("Done") {
			moneyManager.updateOp(operation: moneyOperation)
			presentationMode.wrappedValue.dismiss()
		})
	}
}
