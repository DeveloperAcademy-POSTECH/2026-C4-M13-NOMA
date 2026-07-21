//
//  InterviewPracticeReducer.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import Foundation

struct Effect<Action> {
    typealias Send = (Action) async -> Void
    private let operation: ((Send) async -> Void)?

    static var none: Effect { Effect(operation: nil) }

    static func run(
        _ operation: @escaping (Send) async -> Void
    ) -> Effect {
        Effect(operation: operation)
    }

    func run(_ send: @escaping (Action) -> Void) async {
        guard let operation else { return }
        await operation { action in
            send(action)
        }
    }
}

final class InterviewPracticeReducer {
    private let audioRecorder: AudioRecording
    private let questionSpeaker: QuestionSpeaking
    private let speechTranscribing: SpeechTranscribing
    private let interviewFeedbackGenerating: InterviewFeedbackGenerating
    private let followUpQuestionGenerating: FollowUpQuestionGenerating
    private let maximumRecordingDuration: Duration = .seconds(180)

    init(
        audioRecorder: AudioRecording,
        questionSpeaker: QuestionSpeaking,
        speechTranscribing: SpeechTranscribing,
        interviewFeedbackGenerating: InterviewFeedbackGenerating,
        followUpQuestionGenerating: FollowUpQuestionGenerating
    ) {
        self.audioRecorder = audioRecorder
        self.questionSpeaker = questionSpeaker
        self.speechTranscribing = speechTranscribing
        self.interviewFeedbackGenerating = interviewFeedbackGenerating
        self.followUpQuestionGenerating = followUpQuestionGenerating
    }
    
    func reduce(
        state: inout InterviewPracticeState,
        action: InterviewPracticeAction
    ) -> Effect<InterviewPracticeAction> {
        switch action {
        case .viewAppeared:
            state.phase = .askingQuestion
            return .none
            
        case .questionSpeechFinished:
            state.phase = .recording
            return .none

        case .finishAnswering, .recordingTimeLimitReached:
            state.phase = .transcribing
            return .none

        case .moveToNextQuestion:
            if let pending = state.session.pendingFollowUpQuestion {
                state.session.questions.append(pending)
                state.session.pendingFollowUpQuestion = nil
            }
            state.session.currentQuestionIndex += 1
            state.phase = state.session.currentQuestionIndex < state.session.questions.count
                ? .askingQuestion : .completed
            return .none

        case .retryCurrentAnswer:
            state.phase = .recording
            return .none

        case .captionsChanged(let enabled):
            state.captionsEnabled = enabled
            return .none

        case .exitRequested:
            state.isExitConfirmationPresented = true
            return .none

        case .exitConfirmed, .exitCancelled, .viewDisappeared:
            return .none
        }
    }
}
