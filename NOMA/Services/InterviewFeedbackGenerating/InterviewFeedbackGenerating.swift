//
//  InterviewFeedbackGenerating.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Foundation

nonisolated protocol InterviewFeedbackGenerating {
    func generateFeedback(sentence: String) async throws(FoundationModelsGenerationError) -> SentenceFeedback?
    func generateOverallFeedback(items: [FeedbackItem]) async throws(FoundationModelsGenerationError) -> String
    func stopFeedback()
}
