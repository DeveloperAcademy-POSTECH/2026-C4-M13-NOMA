//
//  SpeechTranscribing.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Speech

protocol SpeechTranscribing {
    func transcribe(bufferStream: AsyncStream<RecordedAudioBuffer>) async throws
    -> AsyncThrowingStream<TranscriptUpdate, Error>
}
