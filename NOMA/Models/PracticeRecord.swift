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
    
    // MARK: - Properties
    
    var createdAt: Date
    var memo: String
    
    @Relationship(
        deleteRule: .cascade,
        inverse: \QuestionRecord.record
    )
    var questionRecords: [QuestionRecord]
    
    var improvementCount: Int {
        questionRecords.reduce(0) { sum, question in sum + question.feedbackItems.count }
    }
    
    // MARK: - Initializer
    
    init(
        createdAt: Date = .now,
        memo: String = "",
        questions: [QuestionRecord] = []
    ) {
        self.createdAt = createdAt
        self.memo = memo
        self.questionRecords = questions
    }
}
