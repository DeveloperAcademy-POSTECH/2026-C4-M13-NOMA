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

        appendCurrentAnswerToSession(state: &state)

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

    private func appendCurrentAnswerToSession(state: inout InterviewPracticeState) {
        guard let answeredQuestion = state.session.currentQuestion else { return }

        let items: [FeedbackItem] = state.answerSentences.enumerated().compactMap { index, sentence in
            guard case .corrected(let feedback) = sentence.feedbackStatus else { return nil }
            return FeedbackItem(
                sentenceIndex: index,
                revisedSentence: feedback.revisedSentence,
                explanation: feedback.explanation,
                corrections: feedback.corrections
            )
        }

        state.session.answers.append(
            PracticeAnswer(
                question: answeredQuestion,
                transcript: state.finalizedTranscript,
                sentences: state.answerSentences.map(\.text),
                feedbackItems: items,
                overallFeedback: state.overallFeedbackText ?? ""
            )
        )
    }

    private func insertPendingFollowUpQuestionIfNeeded(state: inout InterviewPracticeState) {
        guard var pending = state.session.pendingFollowUpQuestion else { return }

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

        // currentTime은 재생이 자연스럽게 끝나면 0으로 리셋돼서 duration과 비교하면 종료를 못 잡는다.
        // AVAudioPlayer가 직접 관리하는 isPlaying으로 종료 여부를 판단한다.
        guard audioPlayer.isPlaying else {
            audioPlayer.stop()
            return .run { send in
                await send(.sentencePracticePlaybackFinished(index: index))
            }
        }

        let currentTime = audioPlayer.currentTime
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
