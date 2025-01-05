//
//  LandmarksApp.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 22.12.24..
//

import SwiftUI

@main
struct LandmarksApp: App {
    var body: some Scene {
        WindowGroup {
			TabView {
				let moneyManager = MoneyManager()
				let categoryManager = CategoryManager()
				
				MainScreenView()
					.environmentObject(moneyManager)
					.environmentObject(categoryManager)
					.tabItem {
						Image(systemName: "dollarsign.circle")
					}
				
				StatsView()
					.environmentObject(moneyManager)
					.environmentObject(categoryManager)
					.tabItem {
						Image(systemName: "chart.pie")
					}
			}
        }
    }
}
