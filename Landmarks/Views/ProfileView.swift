//
//  ProfileView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 31.3.25..
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct ProfileView: View {
	@EnvironmentObject var signInManager: SignInManager
	@EnvironmentObject var moneyManager: MoneyManager
	@State var isSignedIn = false
	
	var body: some View {
		NavigationView {
			VStack {
				Section {
					if (isSignedIn) {
						HStack {
							Image(systemName: "person.circle.fill")
								.resizable()
								.frame(width: 60, height: 60)
								.clipShape(Circle())
								.padding(.trailing, 8)
							VStack(alignment: .leading) {
								Text(signInManager.getUserName())
									.font(.title2)
									.fontWeight(.bold)
								Text(signInManager.getEmail())
									.font(.subheadline)
									.foregroundColor(.gray)
							}
							Spacer()
						}
						.padding(.vertical, 8)
						
						Spacer()
						
						Button(action: {
							isSignedIn = false
							signInManager.signOut()
						}) {
							Text("Sign out")
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
				.navigationTitle("Profile")
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
			}
		}
	}
}

struct ProfileView_Previews: PreviewProvider {
	static var previews: some View {
		ProfileView()
	}
}

