//
//  AVSpeechSynthesizerService.swift
//  NOMA
//
//  Created by 정승민 on 7/21/26.
//

import AVFoundation
import Foundation

@MainActor
final class AVSpeechSynthesizerService: NSObject, QuestionSpeaking {

    // MARK: - Properties

    private let speechSynthesizer: AVSpeechSynthesizer
    private let speechRate: Float
    private let speechPitch: Float
    private let speechVolume: Float
    private let languageCode = "ko-KR"
    private var speechContinuation: CheckedContinuation<Void, Never>?

    // MARK: - Initializer

    init(
        speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer(),
        speechRate: Float = 0.5,
        speechPitch: Float = 1.0,
        speechVolume: Float = 1.0
    ) {
        self.speechSynthesizer = speechSynthesizer
        self.speechRate = speechRate
        self.speechPitch = speechPitch
        self.speechVolume = speechVolume
        super.init()
        self.speechSynthesizer.delegate = self
    }

    // MARK: - Speaking

    func speak(_ text: String) async throws {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        stopSpeaking()

        let utterance = makeUtterance(text: trimmedText)
        await withCheckedContinuation { continuation in
            speechContinuation = continuation
            speechSynthesizer.speak(utterance)
        }
    }

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: - Private Functions

    private func makeUtterance(text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = speechRate
        utterance.pitchMultiplier = speechPitch
        utterance.volume = speechVolume

        return utterance
    }

    private func resumeSpeechContinuation() {
        speechContinuation?.resume()
        speechContinuation = nil
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AVSpeechSynthesizerService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            resumeSpeechContinuation()
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            resumeSpeechContinuation()
        }
    }
}
