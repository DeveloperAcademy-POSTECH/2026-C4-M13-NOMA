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
    var onListenTapped: (String) -> Void = { _ in }

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

        switch sentence.feedbackStatus {
        case .none:
            EmptyView()

        case .pending:
            HStack(spacing: 8) {
                SpinningRingLoader()
                    .frame(width: 16, height: 16)

                Text("피드백 확인 중")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)

        case .corrected(let feedback):
            CorrectionFeedbackCardView(
                originalText: sentence.text,
                correctedText: feedback.revisedSentence,
                explanation: feedback.explanation,
                onListenTapped: { onListenTapped(feedback.revisedSentence) }
            )
        }
    }
}
