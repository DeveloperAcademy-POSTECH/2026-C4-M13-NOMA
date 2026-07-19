//
//  HomeView.swift
//  NOMA
//
//  Created by 이은지 on 7/19/26.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            greetingHeadlineView
                .padding(30)
            
            startLearningButton
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
            print("학습하기 버튼 클릭")
        }
        .frame(
            width: 300,
            height: 50
        )
    }
}
