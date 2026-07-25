//
//  HomeView.swift
//  NOMA
//
//  Created by 이은지 on 7/19/26.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    
    // MARK: - Properties
    
    @Environment(AppRouter.self) private var router
    @Query private var recentRecords: [PracticeRecord]
    
    // MARK: - Initializer
    
    init() {
        var descriptor = FetchDescriptor<PracticeRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        descriptor.fetchLimit = 3
        _recentRecords = Query(descriptor)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            greetingView
                .padding(.bottom, 30)
            
            startLearningButton
                .padding(.bottom, 166)
            
            learningHistoryTitle
                .padding(.bottom, 40)
            
            if recentRecords.isEmpty {
                learningHistoryEmptyView
            } else {
                learningHistoryContentView
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

// MARK: - Subviews

extension HomeView {
    private var greetingView: some View {
        Text("안녕하십니까.\n오늘도 격식체 연습을 시작해보시겠습니까?")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }
    
    private var startLearningButton: some View {
        CapsuleButton(
            title: "학습하기",
            capsuleButtonType: .primary
        ) {
            router.push(.permission)
        }
        .frame(
            width: 300,
            height: 50
        )
    }
    
    private var learningHistoryTitle: some View {
        Text("학습 기록")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
    }
    
    private var learningHistoryEmptyView: some View {
        VStack(spacing: 8) {
            Text("진행한 학습 내역이 없습니다.")
                .font(.title2)
                .foregroundStyle(.primary)
            
            Text("첫 번째 격식체 연습을 진행해 보십시오.")
                .font(.title3)
                .foregroundStyle(.primary)
        }
    }
    
    private var learningHistoryContentView: some View {
        VStack(spacing: 16) {
            learningHistoryCardListView
            
            PushButton(
                title: "더보기",
                type: .borderless,
                size: .small
            ) {
                router.push(.learningHistory)
            }
        }
    }
    
    private var learningHistoryCardListView: some View {
        HStack(spacing: 20) {
            ForEach(
                Array(recentRecords.enumerated()),
                id: \.element.persistentModelID
            ) { index, record in
                LearningHistoryCardView(
                    record: record,
                    order: index + 1
                )
            }
        }
    }
}
