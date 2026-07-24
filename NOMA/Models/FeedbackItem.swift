//
//  FeedbackItem.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Foundation

struct FeedbackItem: Sendable, Codable {
    let sentenceIndex: Int
    let revisedSentence: String
    let explanation: String
    let corrections: [Correction]
}
