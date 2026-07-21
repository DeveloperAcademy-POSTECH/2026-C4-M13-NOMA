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
    var elapsedRecordingDuration: Duration = .zero
    var isExitConfirmationPresented: Bool = false
    var liveTranscript: String = ""
    var finalizedTranscript: String = ""
    var volatileTranscript: String = ""
    var answerSentences: [AnswerSentence] = []

    var canFinishAnswer: Bool {
        phase == .recording && elapsedRecordingDuration > .seconds(1)
    }
}
