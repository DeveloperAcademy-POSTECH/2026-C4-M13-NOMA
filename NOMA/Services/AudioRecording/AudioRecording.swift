//
//  AudioRecording.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import AVFoundation

protocol AudioRecording {
    func startRecording() throws -> AsyncStream<SendableAudioBuffer>
    func stopRecording() async throws -> RecordedAudio
}
