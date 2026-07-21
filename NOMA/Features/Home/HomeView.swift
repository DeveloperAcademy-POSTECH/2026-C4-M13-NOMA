//
//  HomeView.swift
//  NOMA
//
//  Created by 이은지 on 7/19/26.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Properties

    @Environment(AppRouter.self) private var router

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            greetingHeadlineView
                .padding(.bottom, 30)
            
            startLearningButton
                .padding(.bottom, 166)
            
            learningHistoryTitle
                .padding(.bottom, 40)
            
            // FIXME: - 임시 구현
            HStack(spacing: 20) {
                LearningHistoryCardView()
                
                LearningHistoryCardView()
                
                LearningHistoryCardView()
            }
            .padding(.bottom, 16)
            
            PushButton(
                title: "더보기",
                type: .borderless,
                size: .small
            ) {
                router.push(.learningHistory)
            }
        }
    }
}

// MARK: - SubViews

extension HomeView {
    private var greetingHeadlineView: some View {
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
    
}
