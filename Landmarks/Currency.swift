//
//  Currency.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 26.12.24..
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
	case eur = "EUR"
	case rsd = "RSD"
	
	var id: Self { self }
}
