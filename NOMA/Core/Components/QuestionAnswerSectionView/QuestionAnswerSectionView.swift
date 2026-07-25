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
    var sentencePracticeRecords: [Int: SentencePracticeRecordState] = [:]
    var isSentencePracticeEnabled: Bool = false
    var recordingSentencePracticeIndex: Int?
    var playingSentencePracticeIndex: Int?
    var onListenTapped: (String) -> Void = { _ in /* no-op */ }
    var onSentencePracticeRecordingTapped: (Int) -> Void = { _ in /* no-op */ }
    var onSentencePracticePlaybackTapped: (Int) -> Void = { _ in /* no-op */ }

    // MARK: - Body

    var body: some View {
        Section {
            ForEach(sentences.indices, id: \.self) { index in
                sentenceBlock(
                    sentences[index],
                    index: index
                )
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
        .padding(.bottom, 16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("질문, \(question)")
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private func sentenceBlock(
        _ sentence: AnswerSentence,
        index: Int
    ) -> some View {
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
                sentencePracticeState: sentencePracticeRecords[index],
                isSentencePracticeEnabled: isSentencePracticeControlEnabled(index: index),
                isSentencePracticeRecording: recordingSentencePracticeIndex == index,
                isSentencePracticePlaying: playingSentencePracticeIndex == index,
                onListenTapped: { onListenTapped(feedback.revisedSentence) },
                onSentencePracticeRecordingTapped: {
                    onSentencePracticeRecordingTapped(index)
                },
                onSentencePracticePlaybackTapped: {
                    onSentencePracticePlaybackTapped(index)
                }
            )
        }
    }

    private func isSentencePracticeControlEnabled(index: Int) -> Bool {
        guard isSentencePracticeEnabled else { return false }

        let isOtherCardRecording = recordingSentencePracticeIndex != nil
            && recordingSentencePracticeIndex != index
        let isOtherCardPlaying = playingSentencePracticeIndex != nil
            && playingSentencePracticeIndex != index

        return !isOtherCardRecording && !isOtherCardPlaying
    }
}
