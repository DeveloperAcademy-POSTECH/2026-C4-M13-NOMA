//
//  LearningHistoryView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct LearningHistoryView: View {
    
    // MARK: - Properties
    
    @Environment(AppRouter.self) private var router

    // FIXME: - 예시 데이터, 모델 배열로 교체할 예정
    private let sessionNumbers = Array(1...50).reversed()

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
            ForEach(
                sessionNumbers,
                id: \.self
            ) { _ in
                LearningHistoryCardView()
            }
        }
    }
}
