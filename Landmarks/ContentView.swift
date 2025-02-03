import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct MainScreenView: View {
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var signInManager: SignInManager
	@EnvironmentObject var settingsManager: SettingsManager
	@StateObject private var speechRecognizer = SpeechManager()
	
	@State var isSignedIn = false
	@State private var isRecording = false
	
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
								
								Text(String(format: "%.1f", moneyManager.getBalance()) + "€")
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
								Text(String(format: "%.1f", moneyManager.getIncomeAmount()) + "€")
									.font(.largeTitle)
									.foregroundColor(.white)
								
								Text("Expenses")
									.font(.title3)
									.foregroundColor(.white)
								Text(String(format: "-%.1f", moneyManager.getExpenseAmount()) + "€")
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
				
				if (isSignedIn) {
					Button(action: {
						isSignedIn = false
						signInManager.signOut()
					}) {
						Text("Sign out")
					}
					
					Button(isRecording ? "Stop Recording" : "Start Recording") {
						if isRecording {
							speechRecognizer.stopRecording()
						} else {
							speechRecognizer.requestPermissions()
							speechRecognizer.startRecording(locale: settingsManager.getLocale())
						}
						isRecording.toggle()
					}
					.padding()
					
					Text(speechRecognizer.transcribedText)
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
