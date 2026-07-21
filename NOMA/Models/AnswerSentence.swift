//
//  AnswerSentence.swift
//  NOMA
//
//  Created by 이은지 on 7/22/26.
//

import Foundation

struct AnswerSentence {
    let text: String
    var feedbackStatus: FeedbackStatus = .none
}

extension AnswerSentence {
    /// 문장 하나의 격식체 피드백 진행 상태
    enum FeedbackStatus {
        case none                        // 교정 불필요 또는 아직 요청 전 (아무것도 표시 안 함)
        case pending                     // 피드백 생성 중 (로더 표시)
        case corrected(SentenceFeedback) // 교정 피드백 도착 (교정 카드 표시)
    }
}

extension AnswerSentence {
    static func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        var current = ""

        for character in text {
            current.append(character)

            if character == "." || character == "?" || character == "!" {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { sentences.append(trimmed) }
                current = ""
            }
        }

        let remainder = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !remainder.isEmpty { sentences.append(remainder) }

        return sentences
    }
}
