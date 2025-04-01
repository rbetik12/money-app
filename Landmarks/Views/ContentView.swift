import SwiftUI

struct BalanceCardView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var settingsManager: SettingsManager
	@State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
	@State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
	
	var balanceGradient: LinearGradient {
		let ratio = moneyManager.getIncomeAmount(month: selectedMonth, year: selectedYear) / max(moneyManager.getExpenseAmount(month: selectedMonth, year: selectedYear), 1)
		let colors: [Color] = ratio >= 1 ? [Color.green.opacity(0.8), Color.green] : [Color.red.opacity(0.8), Color.red]
		return LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Total Balance")
				.font(.title2)
				.bold()
				.foregroundColor(.white)
			
			Text("$ \(String(format: "%.2f", moneyManager.getBalance(month: selectedMonth, year: selectedYear)))")
				.font(.system(size: 40, weight: .bold))
				.foregroundColor(.white)
			
			HStack {
				VStack(alignment: .leading) {
					Text("Income")
						.font(.title3)
						.foregroundColor(.white)
					Text("$ \(String(format: "%.2f", moneyManager.getIncomeAmount(month: selectedMonth, year: selectedYear)))")
						.font(.title3)
						.bold()
						.foregroundColor(.white)
				}
				Spacer()
				VStack(alignment: .trailing) {
					Text("Expenses")
						.font(.title3)
						.foregroundColor(.white)
					Text("$ \(String(format: "%.2f", moneyManager.getExpenseAmount(month: selectedMonth, year: selectedYear)))")
						.font(.title3)
						.bold()
						.foregroundColor(.white)
				}
			}
		}
		.padding()
		.frame(maxWidth: .infinity, minHeight: 200)
		.background(balanceGradient)
		.cornerRadius(20)
	}
}
 

struct MainScreenView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var settingsManager: SettingsManager
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .center) {
				BalanceCardView()
				Spacer()
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Money App")
			.navigationBarHidden(true)
			.padding()
		}
	}
}
