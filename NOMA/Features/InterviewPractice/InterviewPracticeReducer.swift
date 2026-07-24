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
    
    // swiftlint:disable cyclomatic_complexity function_body_length
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
            
        case .toggleFeedbackVisibility:
            state.isFeedbackVisibleDefault.toggle()
            state.isFeedbackVisible.toggle()
            return .none

        case .readyCountdownFinished:
            state.phase = .askingQuestion
            return speakCurrentQuestionEffect(session: state.session)
            
        case .questionSpeechFinished, .retryCurrentAnswer:
            state.phase = .recording
            resetAnswerState(&state)
            return startRecordingEffect()

        case .recordingStarted:
            state.elapsedRecordingDuration = .zero
            return .none
          
        case .transcriptUpdated(let text, let isFinal):
            guard isFinal else {
                state.volatileTranscript = text
                state.liveTranscript = state.finalizedTranscript + text
                return .none
            }
            
            state.finalizedTranscript += text
            state.volatileTranscript = ""
            state.liveTranscript = state.finalizedTranscript
            
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
            guard state.answerSentences.indices.contains(index),
                  state.answerSentences[index].text == originalText else { return .none }
            
            state.answerSentences[index].feedbackStatus = feedback.map { .corrected($0) } ?? .none
            return .none
            
        case .finishAnswering, .recordingTimeLimitReached:
            state.phase = .generatingFeedback
            state.overallFeedbackText = nil
            state.isFeedbackVisible = true
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
            
        case .moveToNextQuestion:
            if let answered = state.session.currentQuestion {
                let items: [FeedbackItem] = state.answerSentences.enumerated().compactMap { index, sentence in
                    guard case .corrected(let feedback) = sentence.feedbackStatus else { return nil }
                    return FeedbackItem(sentenceIndex: index, revisedSentence: feedback.revisedSentence,
                                        explanation: feedback.explanation, corrections: feedback.corrections)
                }
                state.session.answers.append(
                    PracticeAnswer(
                        question: answered,
                        transcript: state.finalizedTranscript,
                        sentences: state.answerSentences.map(\.text),
                        feedbackItems: items,
                        overallFeedback: state.overallFeedbackText ?? ""
                    )
                )
            }
            
            if let pending = state.session.pendingFollowUpQuestion {
                let insertIndex = state.session.currentQuestionIndex + 1
                let followUp = InterviewQuestion(
                    questionID: "q\(insertIndex + 1)",
                    content: pending.content,
                    isFollowUp: pending.isFollowUp
                )
                state.session.questions.insert(followUp, at: insertIndex)
                state.session.pendingFollowUpQuestion = nil
            }

            resetAnswerState(&state)
          
            state.session.currentQuestionIndex += 1
            
            state.phase = state.session.currentQuestionIndex < state.session.questions.count
            ? .askingQuestion
            : .completed

            if state.isFeedbackVisibleDefault {
                state.isFeedbackVisible = true
            } else {
                state.isFeedbackVisible = false
            }
            
            return state.phase == .askingQuestion
            ? speakCurrentQuestionEffect(session: state.session)
            : .none
            
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

        case .exitConfirmed:
            state.isExitConfirmationPresented = false
            questionSpeaker.stopSpeaking()
            return forceStopRecordingEffect()

        case .exitCancelled:
            state.isExitConfirmationPresented = false
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
                let feedback = (try? await interviewFeedbackGenerating.generateFeedback(sentence: sentenceText)) ?? nil
                
                await send(.sentenceFeedbackArrived(
                    index: startIndex + offset,
                    originalText: sentenceText,
                    feedback: feedback
                ))
            }
        }
    }
    
    private func generateAnswerReviewEffect(
        currentQuestion: InterviewQuestion?,
        transcript: String,
        sentences: [AnswerSentence]
    ) -> Effect<InterviewPracticeAction> {
        .run { [audioRecorder, interviewFeedbackGenerating, followUpQuestionGenerating] send in
            _ = try? await audioRecorder.stopRecording()
            
            let items: [FeedbackItem] = sentences.enumerated().compactMap { index, sentence in
                guard case .corrected(let feedback) = sentence.feedbackStatus else { return nil }
                return FeedbackItem(
                    sentenceIndex: index,
                    revisedSentence: feedback.revisedSentence,
                    explanation: feedback.explanation,
                    corrections: feedback.corrections
                )
            }
            
            let followUpQuestion = await Self.makeFollowUpQuestion(
                currentQuestion: currentQuestion,
                transcript: transcript,
                followUpQuestionGenerating: followUpQuestionGenerating
            )
            await send(.followUpQuestionGenerated(followUpQuestion))
            
            let overallFeedback = (try? await interviewFeedbackGenerating.generateOverallFeedback(items: items)) ?? ""
            await send(.overallFeedbackGenerated(overallFeedback))
        }
    }
    
    private static func makeFollowUpQuestion(
        currentQuestion: InterviewQuestion?,
        transcript: String,
        followUpQuestionGenerating: FollowUpQuestionGenerating
    ) async -> InterviewQuestion? {
        guard let currentQuestion, !currentQuestion.isFollowUp else { return nil }
        
        return try? await followUpQuestionGenerating.generateFollowUp(
            question: currentQuestion,
            transcript: transcript
        )
    }

    private func resetAnswerState(_ state: inout InterviewPracticeState) {
        state.liveTranscript = ""
        state.finalizedTranscript = ""
        state.volatileTranscript = ""
        state.answerSentences = []
        state.overallFeedbackText = nil
        state.elapsedRecordingDuration = .zero
    }

    private func forceStopRecordingEffect() -> Effect<InterviewPracticeAction> {
        .run { [audioRecorder] _ in
            _ = try? await audioRecorder.stopRecording()
        }
    }
  
    private func startRecordingEffect() -> Effect<InterviewPracticeAction> {
        .run { [audioRecorder, speechTranscribing] send in
            do {
                try? await Task.sleep(for: .seconds(1))
                
                let bufferStream = try audioRecorder.startRecording()
                await send(.recordingStarted)
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
