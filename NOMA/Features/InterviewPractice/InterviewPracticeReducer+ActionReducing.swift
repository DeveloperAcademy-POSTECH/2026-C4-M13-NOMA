//
//  InterviewPracticeReducer+ActionReducing.swift
//  NOMA
//
//  Created by Codex on 7/24/26.
//

import Foundation

// MARK: - Reducers

extension InterviewPracticeReducer {
    func reduceQuestionFlowAction(
        state: inout InterviewPracticeState,
        action: InterviewPracticeAction
    ) -> Effect<InterviewPracticeAction>? {
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

        case .questionSpeechFinished:
            state.phase = .recording
            resetAnswerState(state: &state)
            resetSentencePracticeState(state: &state)
            return startRecordingEffect()

        case .retryCurrentAnswer:
            let shouldStopSentencePracticeRecording = state.recordingSentencePracticeIndex != nil

            state.phase = .recording
            resetAnswerState(state: &state)
            resetSentencePracticeState(state: &state)
            return startRecordingEffect(stoppingCurrentRecording: shouldStopSentencePracticeRecording)

        case .moveToNextQuestion:
            return moveToNextQuestion(state: &state)

        case .viewDisappeared:
            let shouldStopSentencePracticeRecording = state.recordingSentencePracticeIndex != nil

            questionSpeaker.stopSpeaking()
            resetSentencePracticeState(state: &state)
            return shouldStopSentencePracticeRecording
                ? stopSentencePracticeRecordingEffect()
                : .none

        default:
            return nil
        }
    }

    func reduceAnswerFeedbackAction(
        state: inout InterviewPracticeState,
        action: InterviewPracticeAction
    ) -> Effect<InterviewPracticeAction>? {
        switch action {
        case .transcriptUpdated(let text, let isFinal):
            return updateTranscript(state: &state, text: text, isFinal: isFinal)

        case .sentenceFeedbackArrived(let index, let originalText, let feedback):
            guard state.answerSentences.indices.contains(index),
                  state.answerSentences[index].text == originalText else { return .none }

            state.answerSentences[index].feedbackStatus = feedback.map { .corrected($0) } ?? .none
            return .none

        case .finishAnswering, .recordingTimeLimitReached:
            state.phase = .generatingFeedback
            state.overallFeedbackText = nil
            return generateAnswerReviewEffect(
                currentQuestion: state.session.currentQuestion,
                transcript: state.finalizedTranscript,
                sentences: state.answerSentences
            )

        case .followUpQuestionGenerated(let question):
            state.session.pendingFollowUpQuestion = question
            return .none

        case .overallFeedbackGenerated(let text):
            state.overallFeedbackText = text
            state.phase = .reviewing
            return .none

        default:
            return nil
        }
    }

    func reduceSentencePracticeRecordingAction(
        state: inout InterviewPracticeState,
        action: InterviewPracticeAction
    ) -> Effect<InterviewPracticeAction>? {
        switch action {
        case .sentencePracticeRecordingButtonTapped(let index):
            return handleSentencePracticeRecordingButtonTapped(state: &state, index: index)

        case .sentencePracticeRecordingDurationUpdated(let index, let duration):
            guard state.recordingSentencePracticeIndex == index else { return .none }

            state.sentencePracticeRecords[index]?.recordingDuration = duration
            return .none

        case .sentencePracticeRecordingFinished(let index, let recordedAudio):
            guard state.recordingSentencePracticeIndex == index else { return .none }

            state.recordingSentencePracticeIndex = nil
            state.sentencePracticeRecords[index]?.recordedAudio = recordedAudio
            state.sentencePracticeRecords[index]?.recordingDuration = recordedAudio.duration.timeInterval
            state.sentencePracticeRecords[index]?.playbackCurrentTime = 0
            return .none

        case .sentencePracticeFailed(let index):
            handleSentencePracticeFailed(state: &state, index: index)
            return .none

        default:
            return nil
        }
    }

    func reduceSentencePracticePlaybackAction(
        state: inout InterviewPracticeState,
        action: InterviewPracticeAction
    ) -> Effect<InterviewPracticeAction>? {
        switch action {
        case .sentencePracticePlaybackButtonTapped(let index):
            return handleSentencePracticePlaybackButtonTapped(state: &state, index: index)

        case .sentencePracticePlaybackPaused(let index, let currentTime):
            guard state.playingSentencePracticeIndex == index else { return .none }

            state.playingSentencePracticeIndex = nil
            state.sentencePracticeRecords[index]?.playbackCurrentTime = currentTime
            return .none

        case .sentencePracticePlaybackProgressRequested(let index):
            return requestSentencePracticePlaybackProgress(state: &state, index: index)

        case .sentencePracticePlaybackProgressUpdated(let index, let currentTime):
            guard state.playingSentencePracticeIndex == index else { return .none }

            state.sentencePracticeRecords[index]?.playbackCurrentTime = currentTime
            return .none

        case .sentencePracticePlaybackFinished(let index):
            guard state.playingSentencePracticeIndex == index else { return .none }

            state.playingSentencePracticeIndex = nil
            state.sentencePracticeRecords[index]?.playbackCurrentTime = 0
            return .none

        default:
            return nil
        }
    }

    func reduceViewStateAction(
        state: inout InterviewPracticeState,
        action: InterviewPracticeAction
    ) -> Effect<InterviewPracticeAction>? {
        switch action {
        case .correctedSentencePlaybackRequested(let text):
            return .run { [questionSpeaker] _ in
                try? await questionSpeaker.speak(text)
            }

        case .captionsChanged(let enabled):
            state.captionsEnabled = enabled
            return .none

        case .exitRequested:
            state.isExitConfirmationPresented = true
            return .none

        case .exitConfirmed, .exitCancelled:
            return .none

        default:
            return nil
        }
    }
}

private extension Duration {
    var timeInterval: TimeInterval {
        Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
