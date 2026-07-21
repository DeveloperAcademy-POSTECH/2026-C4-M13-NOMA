//
//  AnswerSentence.swift
//  NOMA
//
//  Created by 이은지 on 7/22/26.
//

import Foundation

struct AnswerSentence {
    let text: String
    var feedback: SentenceFeedback?
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
