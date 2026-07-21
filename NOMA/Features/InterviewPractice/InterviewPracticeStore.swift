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
        let effect = reducer.reduce(
            state: &state,
            action: action
        )

        switch action {
        case .questionSpeechFinished, .retryCurrentAnswer:
            startRecordingTimer()

        case .finishAnswering, .recordingTimeLimitReached:
            stopRecordingTimer()

        default:
            break
        }

        Task {
            await effect.run { [weak self] nextAction in
                self?.send(nextAction)
            }
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
}
