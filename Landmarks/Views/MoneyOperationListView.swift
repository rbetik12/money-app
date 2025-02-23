//
//  MoneyOperationListView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 23.2.25..
//

import SwiftUI

struct MoneyOperationsListView: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var moneyManager: MoneyManager
	let category: Category
	
	var body: some View {
		NavigationView {
			List {
				var list = category.expense ? moneyManager.storage.moneyData.expenses : moneyManager.storage.moneyData.incomes
				var filteredList = list.filter { $0.category.name == category.name }
				ForEach(filteredList, id: \.self) { operation in
					NavigationLink(destination: MoneyOperationEditView(moneyOperation: operation)) {
						HStack {
							Text(operation.description)
							Spacer()
							Text("\(operation.amount, specifier: "%.2f") \(operation.currency.rawValue)")
								.foregroundColor(operation.isExpense ? .red : .green)
						}
					}
				}
			}
			.navigationTitle(category.name)
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

