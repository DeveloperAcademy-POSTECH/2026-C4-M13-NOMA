//
//  AVSpeechSynthesizerService.swift
//  NOMA
//
//  Created by 정승민 on 7/21/26.
//

import AVFoundation
import Foundation

final class AVSpeechSynthesizerService: QuestionSpeaking {

    // MARK: - Properties

    private let speechSynthesizer: AVSpeechSynthesizer
    private let speechRate: Float
    private let speechPitch: Float
    private let speechVolume: Float
    private let languageCode = "ko-KR"

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
    }

    // MARK: - Speaking

    func speak(_ text: String) async throws {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        stopSpeaking()

        let utterance = makeUtterance(text: trimmedText)
        speechSynthesizer.speak(utterance)
    }

    func stopSpeaking() {
        guard speechSynthesizer.isSpeaking || speechSynthesizer.isPaused else { return }

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
}
