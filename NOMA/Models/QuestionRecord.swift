//
//  QuestionRecord.swift
//  NOMA
//
//  Created by seokho on 7/23/26.
//

import Foundation
import SwiftData

@Model
final class QuestionRecord {
    var order: Int
    var questionContent: String
    var isFollowUp: Bool
    var transcript: String
    var sentences: [String]
    var feedbackItems: [FeedbackItem]   // ← analysis 대체
    var overallFeedback: String

    var record: PracticeRecord?

    init(order: Int, questionContent: String, isFollowUp: Bool,
         transcript: String, sentences: [String],
         feedbackItems: [FeedbackItem], overallFeedback: String) {
        self.order = order
        self.questionContent = questionContent
        self.isFollowUp = isFollowUp
        self.transcript = transcript
        self.sentences = sentences
        self.feedbackItems = feedbackItems
        self.overallFeedback = overallFeedback
    }
}
