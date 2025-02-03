//
//  MainAppView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 20.1.25..
//

import SwiftUI

struct MainAppView: View {
	var body: some View {
		TabView {
			MainScreenView()
				.tabItem {
					Label("Summary", systemImage: "dollarsign.circle")
				}
				.tag(1)
			
			StatsView()
				.tabItem {
					Label("Stats", systemImage: "chart.pie")
				}
				.tag(2)
			
			SettingsView()
				.tabItem {
					Label("Settings", systemImage: "gear")
				}
				.tag(3)
		}
	}
}

#Preview {
	MainAppView()
}
