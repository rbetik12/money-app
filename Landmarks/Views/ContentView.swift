import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

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
	@EnvironmentObject var signInManager: SignInManager
	@EnvironmentObject var settingsManager: SettingsManager
	
	@State var isSignedIn = false
	@State var voiceRecorderOpened = false
	@State var parsedOperations: [MoneyOperation] = []
	@State var parsedOperationsOpened = false
	@State var incomeViewOpened = false
	@State var expenseViewOpened = false
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .center) {
				BalanceCardView()
				
				VStack {
					Button(action: { expenseViewOpened.toggle() }) {
						Text("Add expense")
					}
					.buttonStyle(BorderedButtonStyle())
					.padding()
					
					Button(action: { incomeViewOpened.toggle() }) {
						Text("Add income")
					}
					.buttonStyle(BorderedButtonStyle())
					.padding()
					Spacer()
				}
				.padding()
				
				if (isSignedIn) {
					Button(action: {
						isSignedIn = false
						signInManager.signOut()
					}) {
						Text("Sign out")
					}
					
					Button(action: {
						voiceRecorderOpened.toggle()
					}) {
						Text("Record voice")
					}
				} else {
					GoogleSignInButton(action: {
						signInManager.googleSignIn(onSuccess: {
							isSignedIn = true
						})
					})
					.frame(maxWidth: .infinity, minHeight: 100)
					.padding()
				}
				
				Spacer()
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Money App")
			.navigationBarHidden(true)
			.padding()
		}
		.onOpenURL { url in
			GIDSignIn.sharedInstance.handle(url)
		}
		.onAppear {
			GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
				if (user == nil) {
					signInManager.signOut()
				} else {
					isSignedIn = true
				}
			}
			
			// Wait a few seconds to load everything
			DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: {
				moneyManager.sync()
			})
		}
		.sheet(isPresented: $voiceRecorderOpened) {
			VoiceRequestView(onResult: { operations in
				parsedOperations = operations
				parsedOperationsOpened = true
			})
		}
		.sheet(isPresented: $parsedOperationsOpened) {
			MoneyOperationsView(operations: parsedOperations)
		}
		.sheet(isPresented: $incomeViewOpened) {
			IncomeView()
		}
		.sheet(isPresented: $expenseViewOpened) {
			ExpenseView()
		}
	}
}
