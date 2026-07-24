//
//  PracticeAnswer.swift
//  NOMA
//
//  Created by seokho on 7/19/26.
//

import Foundation

struct PracticeAnswer {
    let question: InterviewQuestion
    let transcript: String
    let sentences: [String]
    let feedbackItems: [FeedbackItem]
    let overallFeedback: String
}
