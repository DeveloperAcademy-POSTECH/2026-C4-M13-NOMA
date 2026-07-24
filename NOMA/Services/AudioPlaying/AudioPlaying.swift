//
//  AudioPlaying.swift
//  NOMA
//
//  Created by Codex on 7/23/26.
//

import Foundation

protocol AudioPlaying {
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var isPlaying: Bool { get }

    func loadAudio(from fileURL: URL) throws
    func play()
    func pause()
    func seek(to currentTime: TimeInterval)
    func stop()
}
