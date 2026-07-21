//
//  AudioRecording.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

protocol AudioRecording {
    func startRecording() throws -> AsyncStream<RecordedAudioBuffer>
    func stopRecording() async throws -> RecordedAudio
}
