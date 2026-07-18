//
//  FeedbackItem.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Foundation

enum FeedbackItem: Sendable {
    case noIssue(text: String)
    case corrected(CorrectedSentence)
}
