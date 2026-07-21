//
//  AudioRecordingError.swift
//  NOMA
//
//  Created by 정승민 on 7/19/26.
//

enum AudioRecordingError: Error {
    case alreadyRecording
    case notRecording
    case microphonePermissionDenied
    case microphonePermissionNotDetermined
    case invalidInputFormat
    case failedToCreateAudioFile
    case failedToCopyAudioBuffer
    case failedToWriteAudioFile
    case failedToStartEngine
    case missingRecordedFile
}
