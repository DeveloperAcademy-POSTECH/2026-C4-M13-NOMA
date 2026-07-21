//
//  InterviewQuestion.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Foundation
import SwiftData

@Model
final class InterviewQuestion {
    var questionID: String
    var content: String
    var isFollowUp: Bool
    
    init(questionID: String,
         content: String,
         isFollowUp: Bool) {
        self.questionID = questionID
        self.content = content
        self.isFollowUp = isFollowUp
    }
}
