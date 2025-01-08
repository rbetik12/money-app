//
//  LandmarksApp.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 22.12.24..
//

import SwiftUI

@main
struct LandmarksApp: App {
	@Environment(\.scenePhase) private var scenePhase
	private var moneyStorage = MoneyManagerStorage()
	
	var body: some Scene {
		WindowGroup {
			TabView {
				let moneyManager = MoneyManager(storage: moneyStorage)
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
		.onChange(of: scenePhase) { oldState, newScenePhase in
			switch newScenePhase {
			case .inactive:
				Task {
					do {
						try await moneyStorage.save()
					} catch {
						fatalError(error.localizedDescription)
					}
				}
			case .active:
				// Optionally handle becoming active again
				print("App is active")
			case .background:
				// Optionally handle moving to background
				print("App is in background")
			@unknown default:
				break
			}
		}
	}
}
