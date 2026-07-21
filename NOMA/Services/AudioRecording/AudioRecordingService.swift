//
//  AudioRecordingService.swift
//  NOMA
//
//  Created by 앤디 on 7/19/26.
//

import AVFoundation
import Foundation

struct AudioRecordingService {
    
    // MARK: - Properties
    
    let audioEngine = AVAudioEngine()
    
    // MARK: - Functions
    
    func startRecording() throws -> AsyncStream<RecordedAudioBuffer> {
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
                let safeBuffer = RecordedAudioBuffer(pcmBuffer: buffer)
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
