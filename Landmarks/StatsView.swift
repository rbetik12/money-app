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

struct StatsView: View {
	@EnvironmentObject var moneyManager: MockMoneyManager
	
	var body: some View {
		VStack {
			Chart(moneyManager.getOperationsSumByCategory(isExpense: true).map { category, revenue in
				let total = moneyManager.getOperationsSumByCategory(isExpense: true).values.reduce(0, +)
				let percentage = (revenue / total) * 100
				return CategoryOperation(id: category.id, title: category.name, revenue: revenue, percentage: percentage)
			}) { product in
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
					Text(String(format: "%.1f%%", product.percentage))
						.font(.caption)
						.foregroundColor(.white)
					VStack {
						Text(String(format: "%.1f%%", product.percentage)) // Percentage
							.font(.caption2)
							.foregroundColor(.white.opacity(0.8))
					}
				}
			}
			.frame(width: 300, height: 300)
			
			Spacer()
		}
	}
}

#Preview {
	StatsView()
		.environmentObject(MockMoneyManager())
}
