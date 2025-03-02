//
//  Currency.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 26.12.24..
//

import Foundation

enum Currency: String, CaseIterable, Identifiable, Codable {
	case eur = "EUR"
	case rsd = "RSD"
	case usd = "USD"
	
	var id: Self { self }
	
	func getSymbol() -> String {
		switch self {
		case .eur:
			return "€"
		case .rsd:
			return "RSD"
		case .usd:
			return "$"
		}
	}
}
