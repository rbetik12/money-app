//
//  KeychainManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 18.1.25..
//

import Foundation

class KeychainManager {
	static let instance = KeychainManager()
	
	private init() {}
	
	func save(_ data: Data, forKey key: String) {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecValueData as String: data,
			kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
		]
		
		// Delete any existing item
		SecItemDelete(query as CFDictionary)
		
		// Add the new item
		SecItemAdd(query as CFDictionary, nil)
	}
	
	func read(forKey key: String) -> Data? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		
		guard status == errSecSuccess else { return nil }
		
		return item as? Data
	}
	
	func delete(forKey key: String) {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key
		]
		
		SecItemDelete(query as CFDictionary)
	}
}
