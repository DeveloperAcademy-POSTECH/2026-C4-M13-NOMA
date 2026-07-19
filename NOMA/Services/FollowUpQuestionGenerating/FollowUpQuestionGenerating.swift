//
//  FollowUpQuestionGenerating.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Foundation

protocol FollowUpQuestionGenerating {
    func generateFollowUp(
        question: InterviewQuestion,
        transcript: String
    ) async throws -> InterviewQuestion
}
