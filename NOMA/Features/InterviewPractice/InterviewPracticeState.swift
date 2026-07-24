//
//  InterviewPracticeState.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import Foundation

struct InterviewPracticeState {
    var session: PracticeSession
    var phase: PracticePhase = .ready
    var captionsEnabled: Bool = false
    var isFeedbackVisibleDefault: Bool = true
    var isFeedbackVisible: Bool = true
    var elapsedRecordingDuration: Duration = .zero
    var isExitConfirmationPresented: Bool = false
    var liveTranscript: String = ""
    var finalizedTranscript: String = ""
    var volatileTranscript: String = ""
    var answerSentences: [AnswerSentence] = []
    var overallFeedbackText: String?
    var sentencePracticeRecords: [Int: SentencePracticeRecordState] = [:]
    var recordingSentencePracticeIndex: Int?
    var playingSentencePracticeIndex: Int?

    var canFinishAnswer: Bool {
        phase == .recording && elapsedRecordingDuration >= .seconds(1)
    }

    var isSentencePracticeEnabled: Bool {
        phase == .reviewing
    }

    var hasActiveSentencePractice: Bool {
        recordingSentencePracticeIndex != nil || playingSentencePracticeIndex != nil
    }
}

struct SentencePracticeRecordState {
    var recordedAudio: RecordedAudio?
    var recordingDuration: TimeInterval = 0
    var playbackCurrentTime: TimeInterval = 0

    var playbackDuration: TimeInterval {
        guard let recordedAudio else { return 0 }

        return recordedAudio.duration.timeInterval
    }

    var hasRecordedAudio: Bool {
        recordedAudio != nil
    }
}

private extension Duration {
    var timeInterval: TimeInterval {
        Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
