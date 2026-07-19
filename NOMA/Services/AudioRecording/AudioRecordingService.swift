//
//  AudioRecordingService.swift
//  NOMA
//
//  Created by 앤디 on 7/19/26.
//

import Foundation

import AVFoundation

struct AudioRecordingService {
    let audioEngine = AVAudioEngine()
    
    func startRecording() throws -> AsyncStream<SendableAudioBuffer> {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        
        audioEngine.prepare()
        try audioEngine.start()
        print("엔진 시작됨")
        
        let sendableEngine = SendableEngine(engine: audioEngine)
        
        return AsyncStream { continuation in
            inputNode.installTap(
                onBus: 0,
                bufferSize: 64,
                format: recordingFormat
            ) { buffer, when in
                print("\(when) 구간 버퍼 \(buffer.frameLength)만큼 들어옴")
                let safeBuffer = SendableAudioBuffer(pcmBuffer: buffer)
                continuation.yield(safeBuffer)
            }
            
            continuation.onTermination = { @Sendable _ in
                Task { @MainActor in
                    sendableEngine.engine?.inputNode.removeTap(onBus: 0)
                    sendableEngine.engine?.stop()
                    print("엔진 종료됨")
                }
            }
        }
    }
}

struct SendableAudioBuffer: @unchecked Sendable {
    let pcmBuffer: AVAudioPCMBuffer
}

struct SendableEngine: @unchecked Sendable {
    weak var engine: AVAudioEngine?
}
