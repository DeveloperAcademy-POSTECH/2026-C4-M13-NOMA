//
//  SpeechTranscriptionService.swift
//  NOMA
//
//  Created by 앤디 on 7/19/26.
//

import Speech

struct SpeechTranscriptionService {
    let audioRecorder = AudioRecordingService()
    
    let transcriber = SpeechTranscriber(locale: Locale(identifier: "ko-KR"), preset: .progressiveTranscription)
    
//    func transcribe(bufferStream: AsyncStream<SendableAudioBuffer>)
//    -> AsyncThrowingStream<TranscriptUpdate, Error> {
//        
//    }
    
    func requestAssetInstallation() async {
        if let installationRequest = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await installationRequest.downloadAndInstall()
        }
    }
}
