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
    var pendingFollowUpQuestion: InterviewQuestion?

    init(
        questions: [InterviewQuestion] = [],
        currentQuestionIndex: Int = 0,
        answers: [PracticeAnswer] = [],
        overallFeedback: String? = nil,
        pendingFollowUpQuestion: InterviewQuestion? = nil
    ) {
        self.questions = questions
        self.currentQuestionIndex = currentQuestionIndex
        self.answers = answers
        self.overallFeedback = overallFeedback
        self.pendingFollowUpQuestion = pendingFollowUpQuestion
    }

    var currentQuestion: InterviewQuestion? {
        questions.indices.contains(currentQuestionIndex) ? questions[currentQuestionIndex] : nil
    }
}

extension PracticeSession {
    static func makeInitial() -> PracticeSession {
        let questions = BaseInterviewQuestion.allCases.enumerated().map { index, base in
            InterviewQuestion(
                questionID: "q\(index * 2 + 1)",
                content: base.content,
                isFollowUp: false
            )
        }
        return PracticeSession(questions: questions)
    }
}
