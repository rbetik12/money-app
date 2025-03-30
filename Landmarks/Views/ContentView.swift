import SwiftUI

struct BalanceCardView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var settingsManager: SettingsManager
	
	var balanceGradient: LinearGradient {
		let ratio = moneyManager.getIncomeAmount() / max(moneyManager.getExpenseAmount(), 1)
		let colors: [Color] = ratio >= 1 ? [Color.green.opacity(0.8), Color.green] : [Color.red.opacity(0.8), Color.red]
		return LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Total Balance")
				.font(.title2)
				.bold()
				.foregroundColor(.white)
			
			Text("$ \(String(format: "%.2f", moneyManager.getBalance()))")
				.font(.system(size: 40, weight: .bold))
				.foregroundColor(.white)
			
			HStack {
				VStack(alignment: .leading) {
					Text("Income")
						.font(.title3)
						.foregroundColor(.white)
					Text("$ \(String(format: "%.2f", moneyManager.getIncomeAmount()))")
						.font(.title3)
						.bold()
						.foregroundColor(.white)
				}
				Spacer()
				VStack(alignment: .trailing) {
					Text("Expenses")
						.font(.title3)
						.foregroundColor(.white)
					Text("$ \(String(format: "%.2f", moneyManager.getExpenseAmount()))")
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
