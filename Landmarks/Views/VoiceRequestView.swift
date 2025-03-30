//
//  VoiceRequestView.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 17.2.25..
//

import SwiftUI

struct VoiceRequestView: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject var settingsManager: SettingsManager
	@EnvironmentObject var moneyManager: MoneyManager
	@EnvironmentObject var signInManager: SignInManager
	@StateObject private var speechRecognizer = SpeechManager()
	@State private var isRecording = false
	@State private var animationAmount = 1.0
	@State private var isPulsating = false
	@State private var onResultCb: (([MoneyOperation]) -> Void)
	@State private var statusMessage: String = ""
	
	init(onResult: @escaping([MoneyOperation]) -> Void) {
		onResultCb = onResult
	}
	
	var body: some View {
		NavigationView {
			VStack {
				if (signInManager.isSignedIn()) {
					if (statusMessage.isEmpty) {
						Image(systemName: "mic.fill")
							.resizable()
							.scaledToFit()
							.frame(width: 50, height: 50)
							.foregroundColor(isRecording ? .red : .gray)
							.scaleEffect(isRecording && isPulsating ? 1.2 : 1.0)
							.animation(isRecording ?
									   Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
									   : .default, value: isRecording)
						
						Button(isRecording ? "Stop Recording" : "Start Recording") {
							if isRecording {
								speechRecognizer.stopRecording(onSuccess: {})
							} else {
								speechRecognizer.requestPermissions()
								speechRecognizer.startRecording(locale: settingsManager.getLocale())
							}
							isRecording.toggle()
						}
						.padding()
						
						Text(speechRecognizer.transcribedText)
						
					}
					else {
						Text(statusMessage)
					}
				}
				else {
					Text("Please sign in at profile section to use this feature!")
				}
			}
			.navigationTitle("Voice Recogniser")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Close") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Send") {
						moneyManager.sendOperationsText(text: speechRecognizer.transcribedText, onResult: onResultCb)
						statusMessage = "Please wait a few seconds for your speech to be parsed..."
						DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
							dismiss()
						}
					}
					.disabled(speechRecognizer.transcribedText.isEmpty)
				}
			}
			.onAppear {
				speechRecognizer.requestPermissions()
				speechRecognizer.startRecording(locale: settingsManager.getLocale())
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					isPulsating = true
					isRecording = true
				}
			}
			.onDisappear {
				if (isRecording) {
					speechRecognizer.stopRecording(onSuccess: {})
				}
			}
		}
	}
}

	
