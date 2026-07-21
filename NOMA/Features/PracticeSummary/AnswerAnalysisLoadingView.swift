//
//  AnswerAnalysisLoadingView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct AnswerAnalysisLoadingView: View {
    
    // MARK: - Properties
    
    @State private var isShowingExitAlert = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            analyzingStatusView
        }
        .alert(
            "정말 나가시겠습니까?",
            isPresented: $isShowingExitAlert
        ) {
            Button(
                "나가기",
                role: .destructive
            ) {
                print("종료 확정됨")
            }
            Button(
                "취소",
                role: .cancel
            ) {
            }
        } message: {
            Text("지금 화면을 벗어나시면 지금까지 진행된 면접 내용과 설정 정보는 저장되지 않습니다. 그래도 종료하시겠습니까?")
        }
    }
}

// MARK: - SubViews

extension AnswerAnalysisLoadingView {
    private var analyzingStatusView: some View {
        VStack(spacing: 20) {
            SpinningRingLoader()
                .frame(width: 32, height: 32)
            
            Text("답변을 분석하고 있습니다.")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("잠시만 기다려 주십시오.")
                .font(.title2)
                .foregroundStyle(.primary)
        }
    }
}
