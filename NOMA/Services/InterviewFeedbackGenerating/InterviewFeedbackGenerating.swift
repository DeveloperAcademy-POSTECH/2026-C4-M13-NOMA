//
//  InterviewFeedbackGenerating.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Foundation

nonisolated protocol InterviewFeedbackGenerating {
    func generateFeedback(sentence: String) async throws(FeedbackGenerationError) -> SentenceFeedback?
    func generateOverallFeedback(items: [FeedbackItem]) async throws(FeedbackGenerationError) -> String
    func stopFeedback()
}

struct SentenceFeedback {
    let revisedSentence: String
    let explanation: String
}

enum FeedbackGenerationError: Error {
    case contextWindowExceeded
    case guardrailViolation
    case generationFailed
}
