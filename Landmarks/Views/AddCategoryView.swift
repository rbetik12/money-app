//
//  AddCategoryView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 16.2.25..
//

import SwiftUI

struct AddCategoryView: View {
	@Environment(\.dismiss) private var dismiss
	@ObservedObject var settingsManager: SettingsManager
	
	@State private var name: String = ""
	@State private var selectedImage: String = "folder"
	@State private var isExpense: Bool = true
	
	let sfSymbols = ["folder", "cart", "creditcard", "house", "car", "gift", "heart", "airplane"]

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Category Name")) {
					TextField("Enter name", text: $name)
				}
				
				Section(header: Text("Choose Icon")) {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack {
							ForEach(sfSymbols, id: \.self) { symbol in
								Button(action: {
									selectedImage = symbol
								}) {
									Image(systemName: symbol)
										.font(.largeTitle)
										.padding()
										.background(selectedImage == symbol ? Color.blue.opacity(0.3) : Color.clear)
										.clipShape(Circle())
								}
							}
						}
					}
				}
				
				Section(header: Text("Expense Type")) {
					Toggle("Is Expense", isOn: $isExpense)
				}
			}
			.navigationTitle("New Category")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Save") {
						var newCategory = Category(aName: name, anImageName: selectedImage, isExpense: isExpense)
						newCategory.colorHex = settingsManager.getCategoryColor(uuid: newCategory.id)
						settingsManager.addCategory(newCategory)
						dismiss()
					}
					.disabled(name.isEmpty)
				}
			}
		}
	}
}


#Preview {
	AddCategoryView(settingsManager: SettingsManager())
}
