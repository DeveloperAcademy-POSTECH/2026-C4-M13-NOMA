//
//  PracticeSession.swift
//  NOMA
//
//  Created by seokho on 7/19/26.
//

import Foundation
import SwiftData

@Model
final class PracticeSession {
    var questions: [InterviewQuestion]
    var currentQuestionIndex: Int
    var answers: [PracticeAnswer]
    var overallFeedback: String?
    
    init(questions: [InterviewQuestion],
         currentQuestionIndex: Int,
         answers: [PracticeAnswer],
         overallFeedback: String? = nil) {
        self.questions = questions
        self.currentQuestionIndex = currentQuestionIndex
        self.answers = answers
        self.overallFeedback = overallFeedback
    }
}
