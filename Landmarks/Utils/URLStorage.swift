//
//  URLStorage.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 18.1.25..
//

import Foundation

class URLStorage {
	public static func getBackendHost() -> String {
		let isProd = false
		return isProd ? getProdBackendHost() : getTestBackendHost()
	}
	
	private static func getTestBackendHost() -> String {
		return "http://localhost:3000"
	}
	
	private static func getProdBackendHost() -> String {
		return "";
	}
}
