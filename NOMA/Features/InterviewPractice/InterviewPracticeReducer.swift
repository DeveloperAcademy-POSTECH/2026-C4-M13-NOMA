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
    private let audioPlayer: AudioPlaying
    let questionSpeaker: QuestionSpeaking
    private let speechTranscribing: SpeechTranscribing
    private let interviewFeedbackGenerating: InterviewFeedbackGenerating
    private let followUpQuestionGenerating: FollowUpQuestionGenerating
    private let maximumRecordingDuration: Duration = .seconds(180)
    
    // MARK: - Initializer
    
    init(
        audioRecorder: AudioRecording,
        audioPlayer: AudioPlaying,
        questionSpeaker: QuestionSpeaking,
        speechTranscribing: SpeechTranscribing,
        interviewFeedbackGenerating: InterviewFeedbackGenerating,
        followUpQuestionGenerating: FollowUpQuestionGenerating
    ) {
        self.audioRecorder = audioRecorder
        self.audioPlayer = audioPlayer
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
        if let effect = reduceQuestionFlowAction(state: &state, action: action) {
            return effect
        }

        if let effect = reduceAnswerFeedbackAction(state: &state, action: action) {
            return effect
        }

        if let effect = reduceSentencePracticeRecordingAction(state: &state, action: action) {
            return effect
        }

        if let effect = reduceSentencePracticePlaybackAction(state: &state, action: action) {
            return effect
        }

        if let effect = reduceViewStateAction(state: &state, action: action) {
            return effect

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
            
        case .viewDisappeared:
            questionSpeaker.stopSpeaking()
            return .none
        }

        return .none
    }
}

// MARK: - Functions

extension InterviewPracticeReducer {
    func speakCurrentQuestionEffect(
        session: PracticeSession,
        stoppingCurrentRecording: Bool = false
    ) -> Effect<InterviewPracticeAction> {
        guard let content = session.currentQuestion?.content else { return .none }
        return .run { [audioRecorder, questionSpeaker] send in
            if stoppingCurrentRecording {
                _ = try? await audioRecorder.stopRecording()
            }

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

    func generateAnswerReviewEffect(
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

    func moveToNextQuestion(state: inout InterviewPracticeState) -> Effect<InterviewPracticeAction> {
        let shouldStopSentencePracticeRecording = state.recordingSentencePracticeIndex != nil
        resetSentencePracticeState(state: &state)
        insertPendingFollowUpQuestionIfNeeded(state: &state)
        resetAnswerState(state: &state)
        state.session.currentQuestionIndex += 1

        state.phase = state.session.currentQuestionIndex < state.session.questions.count
        ? .askingQuestion
        : .completed

        guard state.phase == .askingQuestion else {
            return shouldStopSentencePracticeRecording
                ? stopSentencePracticeRecordingEffect()
                : .none
        }

        return speakCurrentQuestionEffect(
            session: state.session,
            stoppingCurrentRecording: shouldStopSentencePracticeRecording
        )
    }

    private func insertPendingFollowUpQuestionIfNeeded(state: inout InterviewPracticeState) {
        guard let pending = state.session.pendingFollowUpQuestion else { return }

        let insertIndex = state.session.currentQuestionIndex + 1
        pending.questionID = "q\(insertIndex + 1)"
        state.session.questions.insert(pending, at: insertIndex)
        state.session.pendingFollowUpQuestion = nil
    }

    func updateTranscript(
        state: inout InterviewPracticeState,
        text: String,
        isFinal: Bool
    ) -> Effect<InterviewPracticeAction> {
        guard isFinal else {
            state.volatileTranscript = text
            state.liveTranscript = state.finalizedTranscript + text
            return .none
        }

        state.finalizedTranscript += text
        state.volatileTranscript = ""
        state.liveTranscript = state.finalizedTranscript

        return appendFinalizedSentences(state: &state, text: text)
    }

    private func appendFinalizedSentences(
        state: inout InterviewPracticeState,
        text: String
    ) -> Effect<InterviewPracticeAction> {
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
    }

    func startRecordingEffect(stoppingCurrentRecording: Bool = false) -> Effect<InterviewPracticeAction> {
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
                if stoppingCurrentRecording {
                    _ = try? await audioRecorder.stopRecording()
                }

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

    func stopSentencePracticeRecordingEffect() -> Effect<InterviewPracticeAction> {
        .run { [audioRecorder] _ in
            _ = try? await audioRecorder.stopRecording()
        }
    }

    func handleSentencePracticeRecordingButtonTapped(
        state: inout InterviewPracticeState,
        index: Int
    ) -> Effect<InterviewPracticeAction> {
        guard state.isSentencePracticeEnabled else { return .none }

        if state.recordingSentencePracticeIndex == index {
            return finishSentencePracticeRecordingEffect(index: index)
        }

        guard !state.hasActiveSentencePractice else { return .none }

        state.sentencePracticeRecords[index] = SentencePracticeRecordState()
        state.recordingSentencePracticeIndex = index
        return startSentencePracticeRecordingEffect(index: index)
    }

    func handleSentencePracticeFailed(
        state: inout InterviewPracticeState,
        index: Int
    ) {
        if state.recordingSentencePracticeIndex == index {
            state.recordingSentencePracticeIndex = nil
        }

        if state.playingSentencePracticeIndex == index {
            state.playingSentencePracticeIndex = nil
        }

        audioPlayer.stop()
    }

    private func startSentencePracticeRecordingEffect(index: Int) -> Effect<InterviewPracticeAction> {
        .run { [audioRecorder] send in
            do {
                let bufferStream = try audioRecorder.startRecording()
                for await _ in bufferStream where Task.isCancelled {
                    break
                }
            } catch {
                await send(.sentencePracticeFailed(index: index))
            }
        }
    }

    private func finishSentencePracticeRecordingEffect(index: Int) -> Effect<InterviewPracticeAction> {
        .run { [audioRecorder] send in
            do {
                let recordedAudio = try await audioRecorder.stopRecording()
                await send(.sentencePracticeRecordingFinished(
                    index: index,
                    recordedAudio: recordedAudio
                ))
            } catch {
                await send(.sentencePracticeFailed(index: index))
            }
        }
    }

    private func startSentencePracticePlaybackEffect(
        index: Int,
        recordedAudio: RecordedAudio,
        currentTime: TimeInterval
    ) -> Effect<InterviewPracticeAction> {
        .run { [audioPlayer] send in
            do {
                try audioPlayer.loadAudio(from: recordedAudio.fileURL)
                audioPlayer.seek(to: currentTime)
                audioPlayer.play()
            } catch {
                await send(.sentencePracticeFailed(index: index))
            }
        }
    }

    func handleSentencePracticePlaybackButtonTapped(
        state: inout InterviewPracticeState,
        index: Int
    ) -> Effect<InterviewPracticeAction> {
        guard state.isSentencePracticeEnabled else { return .none }

        if state.playingSentencePracticeIndex == index {
            return pauseSentencePracticePlayback(index: index)
        }

        guard !state.hasActiveSentencePractice,
              let record = state.sentencePracticeRecords[index],
              let recordedAudio = record.recordedAudio else { return .none }

        state.playingSentencePracticeIndex = index
        return startSentencePracticePlaybackEffect(
            index: index,
            recordedAudio: recordedAudio,
            currentTime: record.playbackCurrentTime
        )
    }

    private func pauseSentencePracticePlayback(index: Int) -> Effect<InterviewPracticeAction> {
        let currentTime = audioPlayer.currentTime
        audioPlayer.pause()
        return .run { send in
            await send(.sentencePracticePlaybackPaused(
                index: index,
                currentTime: currentTime
            ))
        }
    }

    func requestSentencePracticePlaybackProgress(
        state: inout InterviewPracticeState,
        index: Int
    ) -> Effect<InterviewPracticeAction> {
        guard state.playingSentencePracticeIndex == index else { return .none }

        let currentTime = audioPlayer.currentTime
        guard audioPlayer.duration > 0, currentTime < audioPlayer.duration else {
            audioPlayer.stop()
            return .run { send in
                await send(.sentencePracticePlaybackFinished(index: index))
            }
        }

        return .run { send in
            await send(.sentencePracticePlaybackProgressUpdated(
                index: index,
                currentTime: currentTime
            ))
        }
    }

    func resetAnswerState(state: inout InterviewPracticeState) {
        state.elapsedRecordingDuration = .zero
        state.liveTranscript = ""
        state.finalizedTranscript = ""
        state.volatileTranscript = ""
        state.answerSentences = []
        state.overallFeedbackText = nil
    }

    func resetSentencePracticeState(state: inout InterviewPracticeState) {
        audioPlayer.stop()
        state.sentencePracticeRecords = [:]
        state.recordingSentencePracticeIndex = nil
        state.playingSentencePracticeIndex = nil
    }
}

// MARK: - Duration

private extension Duration {
    var timeInterval: TimeInterval {
        Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
