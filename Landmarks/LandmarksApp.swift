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
	
	private let moneyManager = MoneyManager(storage: MoneyManagerStorage())
	private let categoryManager = CategoryManager()
	private let signInManager = SignInManager()
	private let settingsManager = SettingsManager()
	
	var body: some Scene {
		WindowGroup {
			MainAppView()
				.environmentObject(moneyManager)
				.environmentObject(categoryManager)
				.environmentObject(signInManager)
				.environmentObject(settingsManager)
		}
		.onChange(of: scenePhase) { newScenePhase in
			switch newScenePhase {
			case .inactive:
				Task {
					do {
						try await moneyManager.storage.save()
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
