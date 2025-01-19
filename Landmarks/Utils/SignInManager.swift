//
//  SignInProvider.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 18.1.25..
//

import Foundation
import GoogleSignIn

class SignInManager : ObservableObject {
	let TOKEN_KEYCHAIN_KEY = "jwtToken"
	
	func isSignedIn() -> Bool {
		return getToken() != ""
	}
	
	func getToken() -> String {
		if let data = KeychainManager.instance.read(forKey: TOKEN_KEYCHAIN_KEY),
		   let token = String(data: data, encoding: .utf8) {
			return token
		}
		return ""
	}
	
	func googleSignIn() {
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
			let accessToken = user.user.accessToken.tokenString
			let idToken = user.user.idToken!.tokenString
			
			self.verifyGoogleToken(idToken: idToken, refreshToken: user.user.refreshToken.tokenString)
		}
	}
	
	func signOut() {
		GIDSignIn.sharedInstance.signOut()
		KeychainManager.instance.delete(forKey: TOKEN_KEYCHAIN_KEY)
	}
	
	private func verifyGoogleToken(idToken: String, refreshToken: String) {
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
				print("Response: \(token)")
			}
		}.resume()
	}
	
	private func setToken(token: String) {
		if let data = token.data(using: .utf8) {
			KeychainManager.instance.save(data, forKey: TOKEN_KEYCHAIN_KEY)
			print("JWT token saved to Keychain")
		}
	}
}
