//
//  InterviewPracticeReducer.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import Foundation

struct Effect<Action> {
    
    // MARK: - Propertise
    
    typealias Send = (Action) async -> Void
    private let operation: ((Send) async -> Void)?

    static var none: Effect { Effect(operation: nil) }

    // MARK: - Functions
    
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
    
    // MARK: - Properties
    
    private let audioRecorder: AudioRecording
    private let questionSpeaker: QuestionSpeaking
    private let speechTranscribing: SpeechTranscribing
    private let interviewFeedbackGenerating: InterviewFeedbackGenerating
    private let followUpQuestionGenerating: FollowUpQuestionGenerating
    private let maximumRecordingDuration: Duration = .seconds(180)

    // MARK: - Initializer
    
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
    
    // MARK: - Functions
    
    func reduce(
        state: inout InterviewPracticeState,
        action: InterviewPracticeAction
    ) -> Effect<InterviewPracticeAction> {
        switch action {
            
        case .viewAppeared:
            return .run { [questionSpeaker] send in
                try? await questionSpeaker.speak(BaseInterviewQuestion.readyPromptText)
                try? await Task.sleep(for: .seconds(5))
                await send(.readyCountdownFinished)
            }

        case .readyCountdownFinished:
            state.phase = .askingQuestion
            return speakCurrentQuestionEffect(session: state.session)

        case .questionSpeechFinished, .retryCurrentAnswer:
            state.phase = .recording
            state.elapsedRecordingDuration = .zero
            state.liveTranscript = ""
            return startRecordingEffect()

        case .transcriptUpdated(let text):
            state.liveTranscript = text
            return .none

        case .finishAnswering, .recordingTimeLimitReached:
            state.phase = .transcribing
            return .run { [audioRecorder] _ in
                _ = try? await audioRecorder.stopRecording()
            }

        case .moveToNextQuestion:
            if let pending = state.session.pendingFollowUpQuestion {
                let insertIndex = state.session.currentQuestionIndex + 1
                pending.questionID = "q\(insertIndex + 1)"
                state.session.questions.insert(pending, at: insertIndex)
                state.session.pendingFollowUpQuestion = nil
            }

            state.session.currentQuestionIndex += 1

            state.phase = state.session.currentQuestionIndex < state.session.questions.count
            ? .askingQuestion
            : .completed

            return state.phase == .askingQuestion
                ? speakCurrentQuestionEffect(session: state.session)
                : .none

        case .captionsChanged(let enabled):
            state.captionsEnabled = enabled
            return .none

        case .exitRequested:
            state.isExitConfirmationPresented = true
            return .none

        case .exitConfirmed, .exitCancelled:
            return .none

        case .viewDisappeared:
            questionSpeaker.stopSpeaking()
            return .none
        }
    }
}

// MARK: - Functions

extension InterviewPracticeReducer {
    private func speakCurrentQuestionEffect(session: PracticeSession) -> Effect<InterviewPracticeAction> {
        guard let content = session.currentQuestion?.content else { return .none }
        return .run { [questionSpeaker] send in
            try? await questionSpeaker.speak(content)
            await send(.questionSpeechFinished)
        }
    }

    private func startRecordingEffect() -> Effect<InterviewPracticeAction> {
        .run { [audioRecorder, speechTranscribing] send in
            do {
                try? await Task.sleep(for: .seconds(1))

                let bufferStream = try audioRecorder.startRecording()
                let transcriptStream = try await speechTranscribing.transcribe(bufferStream: bufferStream)
                for try await update in transcriptStream {
                    await send(.transcriptUpdated(String(update.text.characters)))
                }
            } catch {
                return
            }
        }
    }
}
