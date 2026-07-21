//
//  AnswerAnalysis.swift
//  NOMA
//
//  Created by seokho on 7/19/26.
//

nonisolated enum AnswerAnalysis: Codable {
    case noFeedback
    case feedback([FeedbackItem])
}
