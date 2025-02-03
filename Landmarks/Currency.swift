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
}
