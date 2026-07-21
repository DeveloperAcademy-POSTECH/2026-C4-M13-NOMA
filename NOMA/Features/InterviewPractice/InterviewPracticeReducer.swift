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
            state.volatileTranscript = ""
            state.answerSentences = []
            return startRecordingEffect()

        case .transcriptUpdated(let text, let isFinal):
            guard isFinal else {
                state.volatileTranscript = text
                state.liveTranscript = state.finalizedTranscript + text
                return .none
            }

            state.finalizedTranscript += text
            state.volatileTranscript = ""
            state.liveTranscript = state.finalizedTranscript

            // 확정된 문장은 즉시 카드로 추가하고, 곧바로 격식체 피드백 생성을 요청한다.
            let newSentences = AnswerSentence.splitIntoSentences(text)
            guard !newSentences.isEmpty else { return .none }

            let startIndex = state.answerSentences.count
            state.answerSentences.append(
                contentsOf: newSentences.map { AnswerSentence(text: $0, feedbackStatus: .pending) }
            )
            return generateSentenceFeedbackEffect(
                sentences: newSentences,
                startIndex: startIndex
            )

        case .sentenceFeedbackArrived(let index, let originalText, let feedback):
            // 재답변/다음 질문으로 문장 목록이 초기화된 뒤 도착한 낡은 피드백은 무시한다.
            guard state.answerSentences.indices.contains(index),
                  state.answerSentences[index].text == originalText else { return .none }

            state.answerSentences[index].feedbackStatus = feedback.map { .corrected($0) } ?? .none
            return .none

        case .finishAnswering, .recordingTimeLimitReached:
            state.phase = .reviewing
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

            state.liveTranscript = ""
            state.finalizedTranscript = ""
            state.volatileTranscript = ""
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

    private func generateSentenceFeedbackEffect(
        sentences: [String],
        startIndex: Int
    ) -> Effect<InterviewPracticeAction> {
        .run { [interviewFeedbackGenerating] send in
            for (offset, sentenceText) in sentences.enumerated() {
                // 생성 실패는 교정 불필요(nil)와 동일하게 취급한다.
                // nil이어도 항상 결과를 보내야 해당 문장의 로더가 사라진다.
                let feedback = (try? await interviewFeedbackGenerating.generateFeedback(sentence: sentenceText)) ?? nil

                await send(.sentenceFeedbackArrived(
                    index: startIndex + offset,
                    originalText: sentenceText,
                    feedback: feedback
                ))
            }
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
