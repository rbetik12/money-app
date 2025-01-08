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
}

struct ExpenseRow: View {
	var iconName: String
	var category: String
	var transactions: Int
	var amount: Double
	
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
			Text(String(format: "-%.1f$", amount))
				.font(.headline)
				.foregroundColor(.gray)
		}
	}
}

struct StatsView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var categoryManager: CategoryManager
	
	var body: some View {
		VStack {
			Chart(moneyManager.getOperationsSumByCategory(isExpense: true).map { category, revenue in
				let total = moneyManager.getOperationsSumByCategory(isExpense: true).values.reduce(0, +)
				let percentage = (revenue / total) * 100
				return CategoryOperation(id: category.id, title: category.name, revenue: revenue, percentage: percentage)
			} as [CategoryOperation]) { product in
				SectorMark(
					angle: .value(
						Text(verbatim: product.title),
						product.revenue
					),
					innerRadius: .ratio(0.6),
					angularInset: 8
				)
				.foregroundStyle(
					by: .value(
						"",
						product.title
					)
				)
				.annotation(position: .overlay) { // Add annotation to display percentage
					VStack {
						Text(product.title) // Percentage
							.font(.caption2)
							.foregroundColor(.white.opacity(0.8))
						Text(String(format: "%.1f%%", product.percentage))
							.font(.caption)
							.foregroundColor(.white)
					}
				}
			}
			.frame(width: 300, height: 300)
			.chartLegend(.hidden)
			
			VStack {
				Text("Expenses")
				Divider()
					.background(Color.purple)
					.frame(height: 2)
					.padding(.horizontal, 20)
				
				List {
					ForEach(Array(moneyManager.getOperationsSumByCategory(isExpense: true)), id:\.key.id) { category, revenue in
						ExpenseRow(iconName: category.imageName, category: category.name, transactions: moneyManager.getOperationsByCategory(category: category, isExpense: true).count, amount: revenue)
					}
				}
				.listStyle(PlainListStyle())
			}
			Spacer()
		}
	}
}

#Preview {
	ZStack {
		let moneyManagerStorage = MoneyManagerStorage()
		
		StatsView()
			.environmentObject(MockMoneyManager(storage: moneyManagerStorage) as MoneyManager)
			.environmentObject(CategoryManager())
	}
}
