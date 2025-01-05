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
				MainScreenView()
					.environmentObject(MoneyManager())
					.environmentObject(CategoryManager())
					.tabItem {
						Image(systemName: "dollarsign.circle")
					}
				
//				StatsView()
//					.tabItem {
//						Image(systemName: "chart.pie")
//					}
			}
        }
    }
}
