import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

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
				VStack(alignment: .center) {
					RoundedRectangle(cornerRadius: 25.0)
						.fill(moneyManager.getBalance() >= 0 ? Color.green : Color.red)
						.overlay {
							VStack {
								Text("Account Balance")
									.font(.title3)
									.foregroundColor(.white)
									.padding()
								
								Text(String(format: "%.2f", moneyManager.getBalance()) + " \(settingsManager.currency.getSymbol())")
									.font(.largeTitle)
									.foregroundColor(.white)
							}
						}
						.frame(height: 150)
					
					RoundedRectangle(cornerRadius: 25.0)
						.fill(Color.gray)
						.overlay {
							VStack {
								Text("Income")
									.font(.title3)
									.foregroundColor(.white)
								Text(String(format: "%.2f", moneyManager.getIncomeAmount()) + " \(settingsManager.currency.getSymbol())")
									.font(.largeTitle)
									.foregroundColor(.white)
								
								Text("Expenses")
									.font(.title3)
									.foregroundColor(.white)
								Text(String(format: "%.2f", moneyManager.getExpenseAmount()) + " \(settingsManager.currency.getSymbol())")
									.font(.largeTitle)
									.foregroundColor(.white)
							}
						}
				}
				
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
