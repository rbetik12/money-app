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
			let operations = moneyManager.getOperationsSumByCategory(isExpense: true).map { category, revenue in
				let total = moneyManager.getOperationsSumByCategory(isExpense: true).values.reduce(0, +)
				let percentage = (revenue / total) * 100
				return CategoryOperation(id: category.id, title: category.name, revenue: revenue, percentage: percentage)
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
							with: .color(randomColor(categoryName: operation.title))
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
	
	private func randomColor(categoryName: String) -> Color {
		if (categoryName == "Food") {
			return Color(hex: "#ffa600")
		}
		if (categoryName == "Transport") {
			return Color(hex: "#003f5c")
		}
		if (categoryName == "Shopping") {
			return Color(hex: "#58508d")
		}
		if (categoryName == "Service") {
			return Color(hex: "#bc5090")
		}
		if (categoryName == "Restaurant") {
			return Color(hex: "#ff6361")
		}
		return Color(hex: "#ffffff")
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
