//
//  InterviewPracticeReducer.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import Foundation

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
            state.finalizedTranscript = ""
            state.answerSentences = []
            return startRecordingEffect()

        case .transcriptUpdated(let text, let isFinal):
            if isFinal {
                state.finalizedTranscript += text
                state.liveTranscript = state.finalizedTranscript
            } else {
                state.liveTranscript = state.finalizedTranscript + text
            }
            return .none

        case .finishAnswering, .recordingTimeLimitReached:
            state.phase = .generatingFeedback
            return generateFeedbackEffect(transcript: state.liveTranscript)

        case .feedbackGenerated(let sentences):
            state.answerSentences = sentences
            state.phase = .reviewing
            return .none

        case .moveToNextQuestion:
            if let pending = state.session.pendingFollowUpQuestion {
                let insertIndex = state.session.currentQuestionIndex + 1
                pending.questionID = "q\(insertIndex + 1)"
                state.session.questions.insert(pending, at: insertIndex)
                state.session.pendingFollowUpQuestion = nil
            }

            state.liveTranscript = ""
            state.finalizedTranscript = ""
            state.answerSentences = []
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

    private func generateFeedbackEffect(transcript: String) -> Effect<InterviewPracticeAction> {
        .run { [
            audioRecorder,
            interviewFeedbackGenerating
        ] send in
            _ = try? await audioRecorder.stopRecording()

            var results: [AnswerSentence] = []

            for sentenceText in AnswerSentence.splitIntoSentences(transcript) {
                
                let feedback = (try? await interviewFeedbackGenerating.generateFeedback(sentence: sentenceText)) ?? nil
                results.append(AnswerSentence(text: sentenceText, feedback: feedback))
            }

            await send(.feedbackGenerated(results))
        }
    }

    private func startRecordingEffect() -> Effect<InterviewPracticeAction> {
        .run { [audioRecorder, speechTranscribing] send in
            do {
                try? await Task.sleep(for: .seconds(1))

                let bufferStream = try audioRecorder.startRecording()
                let transcriptStream = try await speechTranscribing.transcribe(bufferStream: bufferStream)
                for try await update in transcriptStream {
                    await send(.transcriptUpdated(
                        text: String(update.text.characters),
                        isFinal: update.isFinal
                    ))
                }
            } catch {
                return
            }
        }
    }
}
