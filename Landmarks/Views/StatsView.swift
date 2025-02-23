//
//  StatsView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 4.1.25..
//

import SwiftUI
import Charts

struct Product: Identifiable {
	let id = UUID()
	let title: String
	let revenue: Double
}

struct CategoryOperation: Identifiable {
	let id: UUID
	let title: String
	let revenue: Double
	let percentage: Double // Add percentage property
	let color: Color
}

struct OperationView: View {
	var iconName: String
	var category: String
	var transactions: Int
	var amount: Double
	var expense: Bool
	
	var body: some View {
		HStack {
			ZStack {
				Circle()
					.frame(width: 40, height: 40)
					.foregroundColor(Color.purple.opacity(0.8))
				Image(systemName: iconName)
					.foregroundColor(.white)
					.font(.headline)
			}
			VStack(alignment: .leading) {
				Text(category)
					.font(.headline)
					.foregroundColor(.gray)
				Text("\(transactions) transactions")
					.font(.subheadline)
					.foregroundColor(.gray)
			}
			Spacer()
			Text(String(format: expense ? "-%.1f€": "%.1f€", amount))
				.font(.headline)
				.foregroundColor(.gray)
		}
	}
}

struct StatsView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var categoryManager: CategoryManager
	@EnvironmentObject var settingsmanager: SettingsManager
	
	@State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
	@State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
	@State private var openedDateSelector: Bool = false
	@State private var openedOperationsListView: Bool = false
	@State private var operationListToShow: [MoneyOperation] = []
	@State private var selectedCategory: Category = Category()
	@State private var isExpense: Bool = true
	
	var body: some View {
		NavigationView {
			VStack {
				Text("Month: \(selectedMonth) Year: \(selectedYear)")
					.onTapGesture {
						openedDateSelector = true
					}
				Spacer()
				Toggle("Is Expense", isOn: $isExpense)
					.toggleStyle(SwitchToggleStyle())
				
				let operations = moneyManager.getOperationsSumByCategory(isExpense: isExpense, month: selectedMonth, year: selectedYear).map { category, revenue in
					let total = moneyManager.getOperationsSumByCategory(isExpense: isExpense, month: selectedMonth, year: selectedYear).values.reduce(0, +)
					let percentage = (revenue / total) * 100
					return CategoryOperation(id: category.id, title: category.name, revenue: revenue, percentage: percentage, color: Color(hex: category.colorHex))
				} as [CategoryOperation]
				
				GeometryReader { geometry in
					let size = min(geometry.size.width, geometry.size.height)
					let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
					let totalRevenue = operations.reduce(0) { $0 + $1.revenue }
					
					Canvas { context, size in
						var startAngle = Angle(degrees: 0)
						
						for operation in operations {
							let endAngle = startAngle + Angle(degrees: (operation.revenue / totalRevenue) * 360)
							let midAngle = (startAngle + endAngle) / 2
							
							let path = Path { path in
								path.move(to: center)
								path.addArc(
									center: center,
									radius: size.width / 2,
									startAngle: startAngle,
									endAngle: endAngle,
									clockwise: false
								)
							}
							
							context.fill(
								path,
								with: .color(operation.color)
							)
							
							let textPosition = CGPoint(
								x: center.x + Foundation.cos(midAngle.radians) * (size.width / 3),
								y: center.y + Foundation.sin(midAngle.radians) * (size.width / 3)
							)
							
							context.draw(Text(operation.title).font(.caption).foregroundColor(.black), at: textPosition)
							
							startAngle = endAngle
						}
					}
					.frame(width: size, height: size)
				}
				.aspectRatio(1, contentMode: .fit)
				
				VStack {
					Text(isExpense ? "Expenses" : "Income")
					Divider()
						.background(Color.purple)
						.frame(height: 2)
						.padding(.horizontal, 20)
					
					List {
						ForEach(Array(moneyManager.getOperationsSumByCategory(isExpense: isExpense, month: selectedMonth, year: selectedYear)), id:\.key.id) { category, revenue in
							let opsList = moneyManager.getOperationsByCategory(category: category, isExpense: isExpense, month: selectedMonth, year: selectedYear)
							
							OperationView(iconName: category.imageName, category: category.name, transactions: opsList.count, amount: revenue, expense: isExpense)
								.onTapGesture {
									operationListToShow = opsList
									selectedCategory = category
									openedOperationsListView = true
								}
						}
					}
					.listStyle(PlainListStyle())
				}
				Spacer()
			}
		}
		.sheet(isPresented: $openedDateSelector) {
			let dateComponents = DateComponents(year: 2020, month: 1, day: 1)
			let specificDate = Calendar.current.date(from: dateComponents)
			
			MonthYearPickerView(minimumDate: specificDate!,
								maximumDate: Date(),
								selectedMonth: $selectedMonth,
								selectedYear: $selectedYear)
			.onChange(of: selectedMonth) { newValue in
				self.selectedMonth = newValue
			}
			.onChange(of: selectedYear) { newValue in
				self.selectedYear = newValue
			}
			.padding()
			.presentationDetents([.height(200)])
		}
		.sheet(isPresented: $openedOperationsListView) {
			MoneyOperationsListView(category: selectedCategory)
		}
	}
}

#Preview {
	let settingsManager = SettingsManager()
	let categoryManager = CategoryManager(settingsManager: settingsManager)
	let moneyManager = MoneyManager(storage: MoneyManagerStorage(), categoryManager: categoryManager)
	
	StatsView()
		.environmentObject(settingsManager)
		.environmentObject(categoryManager)
		.environmentObject(moneyManager)
}
