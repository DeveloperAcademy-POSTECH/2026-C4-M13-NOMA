//
//  PracticeSummaryView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftData
import SwiftUI

struct PracticeSummaryView: View {
    
    // MARK: - Properties
    
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(MemoStore.self) private var memoStore
    let recordID: PersistentIdentifier
    private var record: PracticeRecord? { modelContext.model(for: recordID) as? PracticeRecord }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView(
                title: "학습 결과",
                actionTitle: "홈으로 이동"
            ) {
                router.popToRoot()
            }

            practiceSummaryScrollView
                .frame(width: 800)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
    }
}

// MARK: - SubViews

extension PracticeSummaryView {
    private var practiceSummaryScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                practiceSummaryInfoSection
                    .padding(.vertical, 34)
                Divider().padding(.bottom, 30)

                if let record {
                    ForEach(record.questions.sorted { $0.order < $1.order }) { question in
                        Text("Q\(question.order + 1). \(question.questionContent)")
                            .font(.title2).fontWeight(.semibold)
                            .padding(.bottom, 20)

                        QuestionAnswerSectionView(
                            question: "Q\(question.order + 1). \(question.questionContent)",
                            sentences: question.answerSentences(),
                            onListenTapped: { _ in }
                        )
                        .padding(.bottom, 20)

                        OverallFeedbackCardView(feedbackText: question.overallFeedback)
                            .padding(.bottom, 30)
                    }
                }
            }
            .padding(.bottom, 34)
        }
    }
    
    private var practiceSummaryInfoSection: some View {
        HStack {
            if let createdAt = record?.createdAt {
                Text(createdAt, format: .dateTime.year().month(.twoDigits).day(.twoDigits))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 42)
            }
            
            Text("IT • 개발")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.trailing, 42)
            
            Text("자기소개 • 직무 역량")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.trailing, 42)

            Text("\(record?.questions.count ?? 0)문항")
                .font(.body)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            PushButton(
                title: "􀧵 메모 보기",
                type: .neutral,
                size: .small
            ) {
                if let record { memoStore.text = record.memo }
                openWindow(id: "memo")
            }
        }
    }
}

extension QuestionRecord {
    func answerSentences() -> [AnswerSentence] {
        guard !feedbackItems.isEmpty else {
            return sentences.map { AnswerSentence(text: $0) }
        }
        let byIndex = Dictionary(feedbackItems.map { ($0.sentenceIndex, $0) }, uniquingKeysWith: { first, _ in first })
        return sentences.enumerated().map { index, text in
            guard let item = byIndex[index] else { return AnswerSentence(text: text) }
            return AnswerSentence(text: text, feedbackStatus: .corrected(
                SentenceFeedback(revisedSentence: item.revisedSentence,
                                 explanation: item.explanation, corrections: item.corrections)))
        }
    }
}
