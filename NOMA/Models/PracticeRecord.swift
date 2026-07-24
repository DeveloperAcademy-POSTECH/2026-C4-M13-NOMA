//
//  PracticeRecord.swift
//  NOMA
//
//  Created by seokho on 7/23/26.
//

import Foundation
import SwiftData

@Model
final class PracticeRecord {
    var createdAt: Date
    var memo: String

    @Relationship(deleteRule: .cascade, inverse: \QuestionRecord.record)
    var questions: [QuestionRecord]

    init(createdAt: Date = .now, memo: String = "", questions: [QuestionRecord] = []) {
        self.createdAt = createdAt
        self.memo = memo
        self.questions = questions
    }

    var improvementCount: Int {
        questions.reduce(0) { sum, question in sum + question.feedbackItems.count }
    }}
