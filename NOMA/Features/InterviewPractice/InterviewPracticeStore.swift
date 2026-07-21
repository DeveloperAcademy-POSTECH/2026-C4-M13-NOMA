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
        
        Task {
            await effect.run { [weak self] nextAction in
                self?.send(nextAction)
            }
        }
    }
}
