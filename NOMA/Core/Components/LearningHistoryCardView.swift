//
//  LearningHistoryCardView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct LearningHistoryCardView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            summaryHeaderView
                .padding(.bottom, 12)
            
            resultRow
        }
        .padding(16)
        .overlay(
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous
            )
            .stroke(
                Color(
                    nsColor: .separatorColor
                ),
                lineWidth: 1
            )
        )
    }
}

// MARK: - SubViews

extension LearningHistoryCardView {
    private var summaryHeaderView: some View {
        HStack {
            // FIXME: - 데이터 주입
            Text("1번째 학습")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // FIXME: - 데이터 주입
            Text("2026.07.07")
                .font(
                    .system(
                        size: 16,
                        weight: .regular
                    )
                )
                .foregroundStyle(.secondary)
        }
    }
    
    private var resultRow: some View {
        HStack {
            // FIXME: - 데이터 주입
            Text("개선 사항 8개")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            detailButton
        }
    }
    
    private var detailButton: some View {
        Button {
            // FIXME: - 버튼 액션 구현
            print("자세히 보기 클릭")
        } label: {
            Text("자세히 보기")
                .font(
                    .system(
                        size: 13,
                        weight: .medium
                    )
                )
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(Color.accentColorBackground)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LearningHistoryCardView()
}
