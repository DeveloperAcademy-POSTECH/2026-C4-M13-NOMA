//
//  QuestionAnswerSectionView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct QuestionAnswerSectionView: View {

    // MARK: - Properties

    let question: String
    let answerText: String
    let correction: Correction?

    // TODO: - 추후 데이터 모델로 교체 예정
    
    struct Correction {
        let originalText: String
        let correctedText: String
        let explanation: String
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            questionTitle

            AnswerSentenceCardView(text: answerText)
                .padding(.bottom, 16)

            if let correction {
                CorrectionFeedbackCardView(
                    originalText: correction.originalText,
                    correctedText: correction.correctedText,
                    explanation: correction.explanation
                )
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - SubViews

extension QuestionAnswerSectionView {
    private var questionTitle: some View {
        Text(question)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.bottom, 16)
    }
}
