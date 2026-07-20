//
//  PracticeAnswer.swift
//  NOMA
//
//  Created by seokho on 7/19/26.
//

import Foundation
import SwiftData

@Model
final class PracticeAnswer {
    var question: InterviewQuestion
    var transcript: String
    var sentences: [String]
    var analysis: AnswerAnalysis
    
    init(question: InterviewQuestion, transcript: String, sentences: [String], analysis: AnswerAnalysis) {
        self.question = question
        self.transcript = transcript
        self.sentences = sentences
        self.analysis = analysis
    }
}
