//
//  SpeechTranscriptionService.swift
//  NOMA
//
//  Created by 앤디 on 7/19/26.
//

import AVFoundation
import Speech

struct SpeechTranscriptionService: SpeechTranscribing {
    
    // MARK: - Properties

    let transcriber = SpeechTranscriber(locale: Locale(identifier: "ko-KR"), preset: .progressiveTranscription)
    
    // MARK: - Functions
    
    func requestAssetInstallation() async throws {
        if let installationRequest = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await installationRequest.downloadAndInstall()
        }
    }
    
    func transcribe(bufferStream: AsyncStream<RecordedAudioBuffer>) async throws
    -> AsyncThrowingStream<TranscriptUpdate, Error> {
        try await requestAssetInstallation()

        let (inputSequence, inputContinuation) = AsyncStream.makeStream(of: AnalyzerInput.self)
        let (outputSequence, outputContinuation) = AsyncThrowingStream.makeStream(of: TranscriptUpdate.self)

        guard let targetFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
            print("모듈에 적합한 포맷 찾을 수 없음")
            
            throw AudioError.formatNotFound
        }
        
        let analyzer = SpeechAnalyzer(modules: [transcriber])
        
        do {
            try await analyzer.prepareToAnalyze(in: targetFormat)
            print("analyzer 준비 완료")
        } catch {
            print("analyzer 준비 실패")
        }

        try await analyzer.start(inputSequence: inputSequence)

        Task {
            let recordingStream = bufferStream

            for await sendableBuffer in recordingStream {
                guard let convertedBuffer = convertFormat(
                    inputBuffer: sendableBuffer,
                    sourceFormat: sendableBuffer.pcmBuffer.format,
                    targetFormat: targetFormat
                ) else {
                    print("오디오 포맷 변환 실패")

                    continue
                }

                let analyzerInput = AnalyzerInput(buffer: convertedBuffer)
                inputContinuation.yield(analyzerInput)
            }

            inputContinuation.finish()

            try? await analyzer.finalizeAndFinishThroughEndOfInput()
        }

        Task {
            do {
                for try await result in transcriber.results {
                    let attributedText = result.text
                    let transcriptUpdate = TranscriptUpdate(text: attributedText, isFinal: false)

                    outputContinuation.yield(transcriptUpdate)
                }

                outputContinuation.finish()
            } catch {
                print("STT 변환 실패: \(error)")
                outputContinuation.finish(throwing: error)
            }
        }
        
        return outputSequence
    }
    
    func convertFormat(
        inputBuffer: RecordedAudioBuffer,
        sourceFormat: AVAudioFormat,
        targetFormat: AVAudioFormat
    ) -> AVAudioPCMBuffer? {
        guard let audioConverter = AVAudioConverter(from: sourceFormat, to: targetFormat) else {
            print("AVAudioConverter 생성 실패")
            
            return nil
        }
        
        nonisolated(unsafe) let rawBuffer = inputBuffer.pcmBuffer

        guard rawBuffer.frameLength > 0 else { return nil }

        let capacity = AVAudioFrameCount(
            Double(rawBuffer.frameLength) * (targetFormat.sampleRate / sourceFormat.sampleRate)
        )

        guard capacity > 0 else { return nil }

        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else {
            print("outputBuffer 생성 실패")
            
            return nil
        }
        
        var error: NSError?
        
        let inputBlock: AVAudioConverterInputBlock = { requestedPackets, statusPointer in
            statusPointer.pointee = .haveData
            
            return rawBuffer
        }
        
        audioConverter.convert(to: outputBuffer, error: &error, withInputFrom: inputBlock)
        
        if let error = error {
            print("변환 실패: \(error)")
            
            return nil
        }
        
        return outputBuffer
    }
}
