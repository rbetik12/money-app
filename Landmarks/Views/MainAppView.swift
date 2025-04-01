//
//  MainAppView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 20.1.25..
//

import SwiftUI

struct MainAppView: View {
	@State private var showOptions = false
	@State var parsedOperationsOpened = false
	@State var incomeViewOpened = false
	@State var expenseViewOpened = false
	@State var voiceRecorderOpened = false
	@State var parsedOperations: [MoneyOperation] = []

	var body: some View {
		ZStack {
			// Main TabView
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

				ProfileView()
					.tabItem {
						Label("Profile", systemImage: "person.circle")
					}
			}

			// Detect background taps to close menu
			if showOptions {
				Color.gray.opacity(0.3)
					.edgesIgnoringSafeArea(.all)
					.blur(radius: 10)
					.onTapGesture {
						withAnimation {
							showOptions = false
						}
					}
			}

			// Floating button and menu
			VStack {
				Spacer()
				HStack {
					Spacer()
					ZStack {
						if showOptions {
							VStack(spacing: 15) {
								CircleButton(icon: "mic.fill", color: .blue) {
									voiceRecorderOpened.toggle()
									showOptions = false
								}
								CircleButton(icon: "plus", color: .green) {
									incomeViewOpened.toggle()
									showOptions = false
								}
								CircleButton(icon: "minus", color: .red) {
									expenseViewOpened.toggle()
									showOptions = false
								}
							}
							.transition(.scale)
						}
						else {
							
							Button(action: {
								withAnimation {
									showOptions.toggle()
								}
							}) {
								Image(systemName: "plus")
									.resizable()
									.scaledToFit()
									.frame(width: 25, height: 25)
									.foregroundColor(.white)
									.padding()
									.background(Color.blue)
									.clipShape(Circle())
									.shadow(radius: 5)
							}
						}
					}
					Spacer()
				}
				.padding(.bottom, 60) // Adjusted to sit above the TabView
			}
		}
		.sheet(isPresented: $voiceRecorderOpened) {
			VoiceRequestView(onResult: { operations in
				parsedOperations = operations
				parsedOperationsOpened = true
			})
		}
		.sheet(isPresented: $parsedOperationsOpened) {
			MoneyOperationsView(operations: parsedOperations)
		}
		.sheet(isPresented: $incomeViewOpened) {
			IncomeView()
		}
		.sheet(isPresented: $expenseViewOpened) {
			ExpenseView()
		}
	}
}


struct CircleButton: View {
	let icon: String
	let color: Color
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Image(systemName: icon)
				.resizable()
				.scaledToFit()
				.frame(width: 20, height: 20)
				.foregroundColor(.white)
				.padding()
				.background(color)
				.clipShape(Circle())
				.shadow(radius: 5)
		}
	}
}

#Preview {
	MainAppView()
}

