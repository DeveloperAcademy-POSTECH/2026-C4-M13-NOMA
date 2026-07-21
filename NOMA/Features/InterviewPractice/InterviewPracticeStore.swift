//
//  InterviewPracticeStore.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import AVFoundation

@Observable
final class InterviewPracticeStore {
    var state: InterviewPracticeState
    private let reducer: InterviewPracticeReducer
    private var recordingTimerTask: Task<Void, Never>?

    init(session: PracticeSession, reducer: InterviewPracticeReducer) {
        self.state = InterviewPracticeState(session: session)
        self.reducer = reducer
    }

    func send(_ action: InterviewPracticeAction) {
        let effect = reducer.reduce(state: &state, action: action)
        Task { await effect.run { [weak self] nextAction in
            self?.send(nextAction)
        }}
    }
}

