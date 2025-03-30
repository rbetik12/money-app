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
	@EnvironmentObject var settingsmanager: SettingsManager
	
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
			Text(String(format: expense ? "-%.1f " + settingsmanager.currency.getSymbol() : "%.1f " + settingsmanager.currency.getSymbol(), amount))
				.font(.headline)
				.foregroundColor(.gray)
		}
		.padding(.horizontal, 16) // Pushes content inward from the left and right edges
		.padding(.vertical, 8) // Optional: Adds vertical spacing
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
	
	@State private var currentPage: Int = 0  // 0 = Expense, 1 = Income

	var body: some View {
		NavigationView {
			ScrollView {
				VStack {
					if moneyManager.getAllIncomes().isEmpty && moneyManager.getAllExpenses().isEmpty {
						Text("No data yet")
							.foregroundColor(.secondary)
					} else {
						Text("Month: \(monthName(from: selectedMonth)) Year: \(selectedYear)")
							.onTapGesture {
								openedDateSelector = true
							}
						
						Spacer()

						// Carousel for pie charts
						TabView(selection: $currentPage) {
							PieChartView(isExpense: true, month: selectedMonth, year: selectedYear)
								.tag(0)
							
							PieChartView(isExpense: false, month: selectedMonth, year: selectedYear)
								.tag(1)
						}
						.frame(height: 300) // Adjust height if needed
						.tabViewStyle(.page(indexDisplayMode: .never)) // Hides the page dots
						
						Text(currentPage == 0 ? "Expenses" : "Income")
							.font(.title)
							.bold()

						Divider()
							.background(Color.purple)
							.frame(height: 2)
							.padding(.horizontal, 20)
						
						// Determine if we're showing Expenses or Income based on the current page
						let isExpense = currentPage == 0

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
				}
			}
			.sheet(isPresented: $openedDateSelector) {
				let dateComponents = DateComponents(year: 2020, month: 1, day: 1)
				let specificDate = Calendar.current.date(from: dateComponents)

				MonthYearPickerView(minimumDate: specificDate!,
									maximumDate: Date(),
									selectedMonth: $selectedMonth,
									selectedYear: $selectedYear)
				.padding()
				.presentationDetents([.height(200)])
			}
			.sheet(isPresented: $openedOperationsListView) {
				MoneyOperationsListView(category: $selectedCategory)
			}
		}
	}

	func monthName(from month: Int) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		formatter.dateFormat = "MMMM"
		let dateComponents = DateComponents(calendar: Calendar.current, year: selectedYear, month: month)

		if let date = Calendar.current.date(from: dateComponents) {
			return formatter.string(from: date)
		}

		return "Unknown"
	}
}

// Separate Pie Chart Component for Carousel
struct PieChartView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var categoryManager: CategoryManager
	var isExpense: Bool
	var month: Int
	var year: Int

	var body: some View {
		GeometryReader { geometry in
			let operations = moneyManager.getOperationsSumByCategory(isExpense: isExpense, month: month, year: year)
				.map { category, revenue in
					let total = moneyManager.getOperationsSumByCategory(isExpense: isExpense, month: month, year: year).values.reduce(0, +)
					let percentage = (revenue / total) * 100
					return CategoryOperation(id: category.id, title: category.name, revenue: revenue, percentage: percentage, color: Color(hex: category.colorHex))
				} as [CategoryOperation]

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

					context.fill(path, with: .color(operation.color))

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
	}
}

#Preview {
	let settingsManager = SettingsManager()
	let categoryManager = CategoryManager(settingsManager: settingsManager)
	let moneyManager = MoneyManager(storage: MoneyManagerStorage(settingsManager: settingsManager), categoryManager: categoryManager)
	
	StatsView()
		.environmentObject(settingsManager)
		.environmentObject(categoryManager)
		.environmentObject(moneyManager)
}
