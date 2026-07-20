//
//  SpeechTranscribing.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

protocol SpeechTranscribing {
    func transcribe(bufferStream: AsyncStream<RecordedAudioBuffer>)
    -> AsyncThrowingStream<TranscriptUpdate, Error>
}
