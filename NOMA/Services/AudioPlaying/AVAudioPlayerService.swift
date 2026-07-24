//
//  AVAudioPlayerService.swift
//  NOMA
//
//  Created by 정승민 on 7/23/26.
//

import AVFoundation
import Foundation

final class AVAudioPlayerService: AudioPlaying {

    // MARK: - Properties

    var currentTime: TimeInterval {
        audioPlayer?.currentTime ?? 0
    }

    var duration: TimeInterval {
        audioPlayer?.duration ?? 0
    }

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    private var audioPlayer: AVAudioPlayer?

    // MARK: - Initializer

    init() {
        audioPlayer = nil
    }

    // MARK: - Playing

    func loadAudio(from fileURL: URL) throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw AudioPlayingError.fileNotFound
        }

        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.prepareToPlay()
            audioPlayer = player
        } catch {
            throw AudioPlayingError.failedToLoad
        }
    }

    func play() {
        audioPlayer?.play()
    }

    func pause() {
        audioPlayer?.pause()
    }

    func seek(to currentTime: TimeInterval) {
        guard let audioPlayer else { return }

        audioPlayer.currentTime = clampedTime(
            currentTime,
            duration: audioPlayer.duration
        )
    }

    func stop() {
        guard let audioPlayer else { return }

        audioPlayer.stop()
        audioPlayer.currentTime = 0
    }

    // MARK: - Private Functions

    private func clampedTime(
        _ currentTime: TimeInterval,
        duration: TimeInterval
    ) -> TimeInterval {
        min(
            max(0, currentTime),
            duration
        )
    }
}
