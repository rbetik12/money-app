import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct MainScreenView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var signInManager: SignInManager
	
	var userId: UUID = UUID(uuid: UUID_NULL);
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .center) {
				VStack(alignment: .center) {
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
								Text("Income")
									.font(.title3)
									.foregroundColor(.white)
								Text(String(format: "%.1f", moneyManager.getIncomeAmount()) + "$")
									.font(.largeTitle)
									.foregroundColor(.white)
								
								Text("Expenses")
									.font(.title3)
									.foregroundColor(.white)
								Text(String(format: "-%.1f", moneyManager.getExpenseAmount()) + "$")
									.font(.largeTitle)
									.foregroundColor(.white)
							}
						}
				}
				
				VStack {
					
					NavigationLink(destination: ExpenseView()) {
						Text("Add expense")
					}
					.buttonStyle(BorderedButtonStyle())
					.padding()
					
					NavigationLink(destination: IncomeView()) {
						Text("Add income")
					}
					.buttonStyle(BorderedButtonStyle())
					.padding()
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
			
			if (signInManager.isSignedIn()) {
				Button(action: signInManager.signOut) {
					Text("Sign out")
				}
			} else {
				GoogleSignInButton(action: signInManager.googleSignIn)
			}
		}
		.onOpenURL { url in
			GIDSignIn.sharedInstance.handle(url)
		}
		.onAppear {
			GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
				if (user == nil) {
					signInManager.signOut()
				}
			}
		}
	}
}

#Preview {
	ZStack {
		let moneyManagerStorage = MoneyManagerStorage()
		
		MainScreenView()
			.environmentObject(MoneyManager(storage: moneyManagerStorage))
			.environmentObject(CategoryManager())
			.environmentObject(SignInManager())
	}
}
