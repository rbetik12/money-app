import SwiftUI

struct MainScreenView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .leading) {
				HStack(alignment: .center) {
					RoundedRectangle(cornerRadius: 25.0)
						.fill(Color.red)
						.overlay {
							VStack {
								Text("Account Balance")
									.font(.title3)
									.foregroundColor(.white)
									.padding()
								
								Text(String(format: "%.1f", moneyManager.getBalance()) + "$")
									.font(.largeTitle)
									.foregroundColor(.white)
							}
						}
						.frame(height: 150)
					
					RoundedRectangle(cornerRadius: 25.0)
						.fill(Color.red)
						.overlay {
							VStack {
								Text("+1000$")
									.font(.largeTitle)
									.foregroundColor(.white)
									.padding()
								
								Text("-500$")
									.font(.largeTitle)
									.foregroundColor(.white)
							}
						}
						.frame(height: 150)
				}
				
				RoundedRectangle(cornerRadius: 25.0)
					.fill(Color.red)
					.overlay {
						VStack {
							Text("Cash flow")
								.font(.title3)
								.foregroundColor(.white)
								.padding()
							
							Text("+500 $")
								.font(.largeTitle)
								.foregroundColor(.white)
						}
					}
					.frame(height: 150)
				
				
				HStack {
					Spacer()
					
					NavigationLink(destination: ExpenseView()) {
						Text("Add expense")
					}
					
					NavigationLink(destination: IncomeView()) {
						Text("Add income")
					}
					Spacer()
				}
				.padding()
				
				Spacer()
			}
			.toolbar {
				Image(systemName: "gearshape.fill")
					.font(.title2)
					.foregroundColor(.gray)
					.padding()
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Money App")
			.navigationBarHidden(true)
			.padding()
		}
	}
}

// Data Models
struct Transaction: Identifiable {
	let id = UUID()
	let icon: String
	let category: String
	let amount: String
	let color: Color
}

// Sample Transactions
let transactions = [
	Transaction(icon: "cart.fill", category: "Shopping", amount: "-$450.50", color: .purple),
	Transaction(icon: "car.fill", category: "Transportation", amount: "-$50.00", color: .blue),
	Transaction(icon: "cup.and.saucer.fill", category: "Food & Drinks", amount: "-$20.00", color: .orange)
]

// Tab Items
let tabItems = ["pencil", "list.bullet", "chart.bar", "person.fill"]

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		MainScreenView()
	}
}

