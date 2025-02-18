//
//  MoneyOperationView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 18.2.25..
//

import SwiftUI

struct MoneyOperationsView: View {
	@Environment(\.dismiss) private var dismiss
	let operations: [MoneyOperation]
	
	var expenses: [MoneyOperation] {
		operations.filter { $0.isExpense }
	}
	
	var incomes: [MoneyOperation] {
		operations.filter { !$0.isExpense }
	}
	
	var body: some View {
		NavigationView {
			List {
				if !expenses.isEmpty {
					Section(header: Text("Expenses")) {
						ForEach(expenses) { operation in
							MoneyOperationRow(operation: operation)
						}
					}
				}
				
				if !incomes.isEmpty {
					Section(header: Text("Incomes")) {
						ForEach(incomes) { operation in
							MoneyOperationRow(operation: operation)
						}
					}
				}
			}
			.navigationTitle("Transactions")
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

struct MoneyOperationRow: View {
	let operation: MoneyOperation
	
	var body: some View {
		HStack {
			Image(systemName: operation.category.imageName)
				.resizable()
				.scaledToFit()
				.frame(width: 24, height: 24)
				.foregroundColor(operation.isExpense ? .red : .green)
			
			VStack(alignment: .leading) {
				Text(operation.category.name)
					.font(.headline)
				Text(operation.description)
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
			Spacer()
			
			Text("\(operation.amount, specifier: "%.2f") \(operation.currency.rawValue)")
				.font(.subheadline)
				.bold()
		}
		.padding(.vertical, 4)
	}
}

#Preview {
	MoneyOperationsView(operations: [
		MoneyOperation(id: UUID(), date: Date(), category: Category(aName: "Groceries", anImageName: "cart", isExpense: true), amount: 50.0, description: "Weekly groceries", currency: .eur, isExpense: true),
		MoneyOperation(id: UUID(), date: Date(), category: Category(aName: "Salary", anImageName: "banknote", isExpense: false), amount: 2000.0, description: "Monthly salary", currency: .eur, isExpense: false)
	])
}
