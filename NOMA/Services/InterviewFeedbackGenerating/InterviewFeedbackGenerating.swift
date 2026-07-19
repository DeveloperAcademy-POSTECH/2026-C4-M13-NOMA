//
//  InterviewFeedbackGenerating.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Foundation

protocol InterviewFeedbackGenerating {
    func generateFeedback(
        question: InterviewQuestion,
        transcript: String
    ) async throws -> AnswerFeedback
}
