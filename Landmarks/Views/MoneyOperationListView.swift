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
	@Binding var category: Category
	@State var showAlert: Bool = false
	@State var opToDelete: MoneyOperation?
	@State private var isSelectionMode: Bool = false
	@State private var selectedOperations: Set<MoneyOperation> = []
	@State private var showDeleteSelectedAlert: Bool = false
	
	var body: some View {
		NavigationView {
			VStack {
				if isSelectionMode {
					HStack {
						Text("\(selectedOperations.count) selected")
						Spacer()
						Button(action: {
							if !selectedOperations.isEmpty {
								showDeleteSelectedAlert = true
							}
						}) {
							Text("Delete Selected")
								.foregroundColor(.red)
						}
						.disabled(selectedOperations.isEmpty)
						.padding(.horizontal)
					}
					.padding()
				}
				
				List {
					let list = category.expense ? moneyManager.storage.moneyData.expenses : moneyManager.storage.moneyData.incomes
					let filteredList = list.filter { $0.category.name == category.name }
					
					ForEach(filteredList, id: \.self) { operation in
						if isSelectionMode {
							Button(action: {
								toggleSelection(operation)
							}) {
								HStack {
									Image(systemName: selectedOperations.contains(operation) ? "checkmark.square.fill" : "square")
										.foregroundColor(selectedOperations.contains(operation) ? .blue : .gray)
									
									Text(operation.description)
									Spacer()
									Text("\(operation.amount, specifier: "%.2f") \(operation.currency.rawValue)")
										.foregroundColor(operation.isExpense ? .red : .green)
								}
							}
						} else {
							NavigationLink(destination: MoneyOperationEditView(moneyOperation: operation)) {
								HStack {
									Text(operation.description)
									Spacer()
									Text("\(operation.amount, specifier: "%.2f") \(operation.currency.rawValue)")
										.foregroundColor(operation.isExpense ? .red : .green)
									Spacer()
									Image(systemName: "trash")
										.onTapGesture {
											showAlert = true
											opToDelete = operation
										}
								}
							}
						}
					}
				}
				.alert("Do you really want to delete this operation?", isPresented: $showAlert) {
					Button("Yes", role: .destructive) {
						if let operation = opToDelete {
							moneyManager.deleteOp(operation: operation)
						}
					}
					Button("No", role: .cancel) {}
				}
				.alert("Delete \(selectedOperations.count) selected operations?", isPresented: $showDeleteSelectedAlert) {
					Button("Delete", role: .destructive) {
						for operation in selectedOperations {
							moneyManager.deleteOp(operation: operation)
						}
						selectedOperations.removeAll()
						isSelectionMode = false
					}
					Button("Cancel", role: .cancel) {}
				}
				.navigationTitle(category.name)
				.toolbar {
					ToolbarItem(placement: .navigationBarLeading) {
						Button("Close") {
							dismiss()
						}
					}
					
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(isSelectionMode ? "Done" : "Select") {
							isSelectionMode.toggle()
							if !isSelectionMode {
								selectedOperations.removeAll()
							}
						}
					}
				}
			}
		}
	}
	
	private func toggleSelection(_ operation: MoneyOperation) {
		if selectedOperations.contains(operation) {
			selectedOperations.remove(operation)
		} else {
			selectedOperations.insert(operation)
		}
	}
}

