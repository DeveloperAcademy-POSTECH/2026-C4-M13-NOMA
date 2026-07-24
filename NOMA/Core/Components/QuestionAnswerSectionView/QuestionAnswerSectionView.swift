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

    /// LazyVStack(pinnedViews: [.sectionHeaders])의 자식으로 놓이면 question이 스크롤 시 상단에 고정된다.
    var body: some View {
        Section {
            ForEach(sentences.indices, id: \.self) { index in
                sentenceBlock(sentences[index])
                    .padding(.bottom, 16)
            }
        } header: {
            questionTitle
        }
    }
}

// MARK: - SubViews

extension QuestionAnswerSectionView {
    private var questionTitle: some View {
        HStack {
            Text(question)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.vertical, 16)
        .background(Color(nsColor: .controlBackgroundColor))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("질문, \(question)")
        .accessibilityAddTraits(.isHeader)
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
                    .accessibilityHidden(true)

                Text("피드백 확인 중")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 4)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("피드백 확인 중")

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
