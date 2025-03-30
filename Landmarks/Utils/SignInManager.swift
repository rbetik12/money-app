//
//  SignInProvider.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 18.1.25..
//

import Foundation
import GoogleSignIn

class SignInManager : ObservableObject {
	static let TOKEN_KEYCHAIN_KEY = "jwtToken"
	
	func getToken() -> String {
		if let data = KeychainManager.instance.read(forKey: SignInManager.TOKEN_KEYCHAIN_KEY),
		   let token = String(data: data, encoding: .utf8) {
			return token
		}
		return ""
	}
	
	func googleSignIn(onSuccess: @escaping () -> Void) {
		guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
			print("Client ID not found")
			return
		}
		
		let config = GIDConfiguration(clientID: clientID)
		GIDSignIn.sharedInstance.configuration = config
		
		GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.windows.first!.rootViewController!) { user, error in
			if let error = error {
				print("Error signing in: \(error)")
				return
			}
			
			guard let user = user else { return }
			self.verifyGoogleToken(idToken: user.user.idToken!.tokenString, 
								   refreshToken: user.user.refreshToken.tokenString,
								   onSuccess: onSuccess)
		}
	}
	
	func signOut() {
		GIDSignIn.sharedInstance.signOut()
		signOutInternal()
		KeychainManager.instance.delete(forKey: SignInManager.TOKEN_KEYCHAIN_KEY)
	}
	
	func isSignedIn() -> Bool {
		return !getToken().isEmpty
	}
	
	private func signOutInternal() {
		let token = getToken()
		if (token.isEmpty) {
			return
		}
		
		let url = URL(string: "\(URLStorage.getBackendHost())/v1/auth/signout")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONEncoder().encode(["token": token])
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Error signing out: \(error)")
				return
			}
		}.resume()
	}
	
	private func verifyGoogleToken(idToken: String, refreshToken: String, onSuccess: @escaping () -> Void) {
		let url = URL(string: "\(URLStorage.getBackendHost())/v1/auth/google/signin")!
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONEncoder().encode(["idToken": idToken, "refreshToken": refreshToken])
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("Error verifying token: \(error)")
				return
			}
			
			if let data = data {
				let token = String(data: data, encoding: .utf8)!
				if (token.count <= 0) {
					print("Error: Empty token")
					return
				}
				self.setToken(token: token)
				onSuccess()
			}
		}.resume()
	}
	
	private func setToken(token: String) {
		if let data = token.data(using: .utf8) {
			KeychainManager.instance.save(data, forKey: SignInManager.TOKEN_KEYCHAIN_KEY)
			print("JWT token saved to Keychain. Token: \(token)")
		}
	}
}
