//
//  LearningHistoryView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftData
import SwiftUI

struct LearningHistoryView: View {
    
    // MARK: - Properties
    
    @Environment(AppRouter.self) private var router
    @Query(sort: \PracticeRecord.createdAt, order: .reverse) private var records: [PracticeRecord]

    private let columns = [
        GridItem(.fixed(333.5), spacing: 24),
        GridItem(.fixed(333.5), spacing: 24),
        GridItem(.fixed(333.5), spacing: 24)
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView(
                title: "학습 기록",
                actionTitle: "홈으로 이동"
            ) {
                router.popToRoot()
            }

            learningHistoryScrollView
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
    }
}

// MARK: - SubViews

extension LearningHistoryView {
    private var learningHistoryScrollView: some View {
        ScrollView {
            learningHistoryCardViewList
                .padding(.vertical, 40)
        }
    }
    
    private var learningHistoryCardViewList: some View {
        LazyVGrid(
            columns: columns,
            spacing: 24
        ) {
            ForEach(Array(records.enumerated()), id: \.element.persistentModelID) { index, record in
                LearningHistoryCardView(record: record, order: records.count - index)
            }
        }
    }
}
