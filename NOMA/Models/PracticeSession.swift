//
//  PracticeSession.swift
//  NOMA
//
//  Created by seokho on 7/19/26.
//

import Foundation

final class PracticeSession {
    var questions: [InterviewQuestion]
    var currentQuestionIndex: Int
    var answers: [PracticeAnswer]
    var overallFeedback: String?

    init(
        questions: [InterviewQuestion] = [],
        currentQuestionIndex: Int = 0,
        answers: [PracticeAnswer] = [],
        overallFeedback: String? = nil
    ) {
        self.questions = questions
        self.currentQuestionIndex = currentQuestionIndex
        self.answers = answers
        self.overallFeedback = overallFeedback
    }
}
