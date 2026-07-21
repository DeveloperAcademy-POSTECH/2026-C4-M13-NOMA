//
//  AVAudioRecordingService.swift
//  NOMA
//
//  Created by 정승민 on 7/19/26.
//

import AVFoundation
import Foundation

final class AVAudioRecordingService: AudioRecording {

    // MARK: - Properties

    private let audioEngine: AVAudioEngine
    private let inputBus: AVAudioNodeBus

    private var audioFile: AVAudioFile?
    private var audioFileURL: URL?
    private var recordingStartDate: Date?
    private var bufferContinuation: AsyncStream<RecordedAudioBuffer>.Continuation?
    private var recordingError: AudioRecordingError?
    private var isRecording = false

    // MARK: - Initializer

    init(
        audioEngine: AVAudioEngine = AVAudioEngine(),
        inputBus: AVAudioNodeBus = 0
    ) {
        self.audioEngine = audioEngine
        self.inputBus = inputBus
    }

    // MARK: - Recording

    func startRecording() throws -> AsyncStream<RecordedAudioBuffer> {
        guard !isRecording else { throw AudioRecordingError.alreadyRecording }

        try validateMicrophonePermission()

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: inputBus)

        guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
            throw AudioRecordingError.invalidInputFormat
        }

        let recordingFileURL = try makeRecordingFileURL()
        let recordingFile = try makeAudioFile(
            fileURL: recordingFileURL,
            format: inputFormat
        )
        let stream = makeBufferStream()

        audioFile = recordingFile
        audioFileURL = recordingFileURL
        recordingStartDate = Date()
        recordingError = nil

        inputNode.removeTap(onBus: inputBus)

        inputNode.installTap(
            onBus: inputBus,
            bufferSize: 1_024,
            format: inputFormat
        ) { [weak self] buffer, _ in
            self?.handleAudioBuffer(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true

            return stream
        } catch {
            inputNode.removeTap(onBus: inputBus)
            bufferContinuation?.finish()
            resetRecordingState()

            throw AudioRecordingError.failedToStartEngine
        }
    }

    func stopRecording() async throws -> RecordedAudio {
        guard isRecording else { throw AudioRecordingError.notRecording }

        audioEngine.inputNode.removeTap(onBus: inputBus)
        audioEngine.stop()
        bufferContinuation?.finish()

        if let recordingError {
            resetRecordingState()

            throw recordingError
        }

        guard let audioFileURL else {
            resetRecordingState()

            throw AudioRecordingError.missingRecordedFile
        }

        let duration = makeRecordingDuration()
        resetRecordingState()

        return RecordedAudio(
            fileURL: audioFileURL,
            duration: duration
        )
    }

    // MARK: - Private Functions

    private func validateMicrophonePermission() throws {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return

        case .denied, .restricted:
            throw AudioRecordingError.microphonePermissionDenied

        case .notDetermined:
            throw AudioRecordingError.microphonePermissionNotDetermined

        @unknown default:
            throw AudioRecordingError.microphonePermissionDenied
        }
    }

    private func makeBufferStream() -> AsyncStream<RecordedAudioBuffer> {
        let stream = AsyncStream.makeStream(of: RecordedAudioBuffer.self)
        bufferContinuation = stream.continuation

        return stream.stream
    }

    private func makeRecordingFileURL() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("JeongJoong")
            .appendingPathComponent("Recordings", isDirectory: true)

        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        return directoryURL.appendingPathComponent("recording-\(UUID().uuidString).caf")
    }

    private func makeAudioFile(
        fileURL: URL,
        format: AVAudioFormat
    ) throws -> AVAudioFile {
        do {
            return try AVAudioFile(
                forWriting: fileURL,
                settings: format.settings
            )
        } catch {
            throw AudioRecordingError.failedToCreateAudioFile
        }
    }

    private func handleAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        do {
            guard let audioFile else { throw AudioRecordingError.failedToWriteAudioFile }

            let copiedBuffer = try copyAudioBuffer(buffer)
            try audioFile.write(from: copiedBuffer)
            bufferContinuation?.yield(RecordedAudioBuffer(pcmBuffer: copiedBuffer))
        } catch AudioRecordingError.failedToCopyAudioBuffer {
            recordingError = .failedToCopyAudioBuffer
            bufferContinuation?.finish()
        } catch AudioRecordingError.failedToWriteAudioFile {
            recordingError = .failedToWriteAudioFile
            bufferContinuation?.finish()
        } catch {
            recordingError = .failedToWriteAudioFile
            bufferContinuation?.finish()
        }
    }

    private func copyAudioBuffer(_ buffer: AVAudioPCMBuffer) throws -> AVAudioPCMBuffer {
        guard let copiedBuffer = AVAudioPCMBuffer(
            pcmFormat: buffer.format,
            frameCapacity: buffer.frameLength
        ) else {
            throw AudioRecordingError.failedToCopyAudioBuffer
        }

        copiedBuffer.frameLength = buffer.frameLength

        let sourceBuffers = UnsafeMutableAudioBufferListPointer(buffer.mutableAudioBufferList)
        let destinationBuffers = UnsafeMutableAudioBufferListPointer(copiedBuffer.mutableAudioBufferList)

        for index in 0..<sourceBuffers.count {
            let sourceBuffer = sourceBuffers[index]
            var destinationBuffer = destinationBuffers[index]

            guard
                let sourceData = sourceBuffer.mData,
                let destinationData = destinationBuffer.mData
            else {
                continue
            }

            memcpy(
                destinationData,
                sourceData,
                Int(sourceBuffer.mDataByteSize)
            )

            destinationBuffer.mDataByteSize = sourceBuffer.mDataByteSize
            destinationBuffers[index] = destinationBuffer
        }

        return copiedBuffer
    }

    private func makeRecordingDuration() -> Duration {
        guard let recordingStartDate else { return .zero }

        let elapsedTime = Date().timeIntervalSince(recordingStartDate)

        return .milliseconds(Int64(elapsedTime * 1_000))
    }

    private func resetRecordingState() {
        audioFile = nil
        audioFileURL = nil
        recordingStartDate = nil
        bufferContinuation = nil
        recordingError = nil
        isRecording = false
    }
}
