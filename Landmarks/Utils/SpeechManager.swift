//
//  SpeechManager.swift
//  Landmarks
//
//  Created by Vitaliy Prikota on 2.2.25..
//

import SwiftUI
import Speech
import AVFoundation

class SpeechManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
	@Published var transcribedText: String = "Press the button to start recording"

	private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask: SFSpeechRecognitionTask?
	private let audioEngine = AVAudioEngine()

	override init() {
		super.init()
		speechRecognizer?.delegate = self
	}

	func requestPermissions() {
		SFSpeechRecognizer.requestAuthorization { status in
			DispatchQueue.main.async {
				switch status {
				case .authorized:
					print("Speech recognition authorized")
				case .denied, .restricted, .notDetermined:
					self.transcribedText = "Speech recognition not allowed"
				@unknown default:
					fatalError()
				}
			}
		}
	}

	func startRecording(locale: Locale) {
		do {
			transcribedText = ""
			recognitionTask?.cancel()
			recognitionTask = nil
			
			speechRecognizer = SFSpeechRecognizer(locale: locale)

			let audioSession = AVAudioSession.sharedInstance()
			try audioSession.setCategory(.record, mode: .default, options: .duckOthers)
			try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

			recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
			let inputNode = audioEngine.inputNode
			let recordingFormat = inputNode.outputFormat(forBus: 0)
			inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
				self.recognitionRequest?.append(buffer)
			}

			audioEngine.prepare()
			try audioEngine.start()

			recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
				if let result = result {
					DispatchQueue.main.async {
						self.transcribedText = result.bestTranscription.formattedString
						print(self.transcribedText)
					}
				}
				if error != nil {
					self.stopRecording()
				}
			}
		} catch {
			print("Error starting recording: \(error)")
			stopRecording()
		}
	}

	func stopRecording() {
		audioEngine.stop()
		audioEngine.inputNode.removeTap(onBus: 0)
		recognitionRequest?.endAudio()
		recognitionRequest = nil
		recognitionTask = nil

		do {
			try AVAudioSession.sharedInstance().setActive(false)
		} catch {
			print("Error stopping audio session: \(error)")
		}
	}
}
