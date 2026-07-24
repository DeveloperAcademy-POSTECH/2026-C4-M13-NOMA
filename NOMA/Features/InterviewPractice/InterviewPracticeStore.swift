//
//  InterviewPracticeStore.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import Foundation

@Observable
final class InterviewPracticeStore {
    
    // MARK: - Properties
    
    var state: InterviewPracticeState
    private let reducer: InterviewPracticeReducer
    private var recordingTimerTask: Task<Void, Never>?
    private var sentencePracticeRecordingTimerTask: Task<Void, Never>?
    private var sentencePracticePlaybackTimerTask: Task<Void, Never>?

    // MARK: - Initializer
    
    init(
        session: PracticeSession,
        reducer: InterviewPracticeReducer
    ) {
        self.state = InterviewPracticeState(session: session)
        self.reducer = reducer
    }

    // MARK: - Functions
    
    func send(_ action: InterviewPracticeAction) {
        let previousRecordingIndex = state.recordingSentencePracticeIndex
        let previousPlayingIndex = state.playingSentencePracticeIndex

        let effect = reducer.reduce(
            state: &state,
            action: action
        )

        updateTimers(
            after: action,
            previousRecordingIndex: previousRecordingIndex,
            previousPlayingIndex: previousPlayingIndex
        )

        Task {
            await effect.run { [weak self] nextAction in
                self?.send(nextAction)
            }
        }
    }
}

// MARK: - Timer Routing

extension InterviewPracticeStore {
    private func updateTimers(
        after action: InterviewPracticeAction,
        previousRecordingIndex: Int?,
        previousPlayingIndex: Int?
    ) {
        updateAnswerRecordingTimer(after: action)
        updateSentencePracticeRecordingTimer(
            after: action,
            previousRecordingIndex: previousRecordingIndex
        )
        updateSentencePracticePlaybackTimer(
            after: action,
            previousPlayingIndex: previousPlayingIndex
        )
    }

    private func updateAnswerRecordingTimer(after action: InterviewPracticeAction) {
        switch action {
        case .questionSpeechFinished, .retryCurrentAnswer:
            startRecordingTimer()
            stopSentencePracticeTimers()

        case .finishAnswering, .recordingTimeLimitReached:
            stopRecordingTimer()

        default:
            break
        }
    }

    private func updateSentencePracticeRecordingTimer(
        after action: InterviewPracticeAction,
        previousRecordingIndex: Int?
    ) {
        switch action {
        case .sentencePracticeRecordingButtonTapped(let index):
            if previousRecordingIndex == nil && state.recordingSentencePracticeIndex == index {
                startSentencePracticeRecordingTimer(index: index)
            } else if previousRecordingIndex == index {
                stopSentencePracticeRecordingTimer()
            }

        case .sentencePracticeRecordingFinished:
            stopSentencePracticeRecordingTimer()

        case .sentencePracticeFailed, .moveToNextQuestion, .viewDisappeared:
            stopSentencePracticeRecordingTimer()

        default:
            break
        }
    }

    private func updateSentencePracticePlaybackTimer(
        after action: InterviewPracticeAction,
        previousPlayingIndex: Int?
    ) {
        switch action {
        case .sentencePracticePlaybackButtonTapped(let index):
            if previousPlayingIndex == nil && state.playingSentencePracticeIndex == index {
                startSentencePracticePlaybackTimer(index: index)
            } else if previousPlayingIndex == index {
                stopSentencePracticePlaybackTimer()
            }

        case .sentencePracticePlaybackPaused, .sentencePracticePlaybackFinished:
            stopSentencePracticePlaybackTimer()

        case .sentencePracticeFailed, .moveToNextQuestion, .viewDisappeared:
            stopSentencePracticePlaybackTimer()

        default:
            break
        }
    }
}

// MARK: - Recording Timer

extension InterviewPracticeStore {
    private func startRecordingTimer() {
        recordingTimerTask?.cancel()
        recordingTimerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self else { return }
                self.state.elapsedRecordingDuration += .seconds(1)
            }
        }
    }

    private func stopRecordingTimer() {
        recordingTimerTask?.cancel()
        recordingTimerTask = nil
    }

    private func startSentencePracticeRecordingTimer(index: Int) {
        sentencePracticeRecordingTimerTask?.cancel()
        sentencePracticeRecordingTimerTask = Task { [weak self] in
            var duration: TimeInterval = 0

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self else { return }

                duration += 1
                self.send(.sentencePracticeRecordingDurationUpdated(
                    index: index,
                    duration: duration
                ))
            }
        }
    }

    private func stopSentencePracticeRecordingTimer() {
        sentencePracticeRecordingTimerTask?.cancel()
        sentencePracticeRecordingTimerTask = nil
    }

    private func startSentencePracticePlaybackTimer(index: Int) {
        sentencePracticePlaybackTimerTask?.cancel()
        sentencePracticePlaybackTimerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled, let self else { return }

                self.send(.sentencePracticePlaybackProgressRequested(index: index))
            }
        }
    }

    private func stopSentencePracticePlaybackTimer() {
        sentencePracticePlaybackTimerTask?.cancel()
        sentencePracticePlaybackTimerTask = nil
    }

    private func stopSentencePracticeTimers() {
        stopSentencePracticeRecordingTimer()
        stopSentencePracticePlaybackTimer()
    }
}
