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
    let sentences: [AnswerSentence]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                questionTitle
                
                Spacer()
            }

            ForEach(sentences.indices, id: \.self) { index in
                sentenceBlock(sentences[index])
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

    @ViewBuilder
    private func sentenceBlock(_ sentence: AnswerSentence) -> some View {
        AnswerSentenceCardView(text: sentence.text)

        if let feedback = sentence.feedback {
            CorrectionFeedbackCardView(
                originalText: sentence.text,
                correctedText: feedback.revisedSentence,
                explanation: feedback.explanation
            )
        }
    }
}
