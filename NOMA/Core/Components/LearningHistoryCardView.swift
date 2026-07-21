//
//  LearningHistoryCardView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct LearningHistoryCardView: View {
    
    // MARK: - Properties
    @State private var isHovering: Bool = false
    @Environment(AppRouter.self) private var router
    
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
        .frame(
            width: 333.5,
            height: 102
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
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // FIXME: - 데이터 주입
            Text("2026.07.07")
                .font(.title3)
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
            router.push(.practiceSummary)
        } label: {
            Text("자세히 보기")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(
                    Color.accentColorBackground
                        .opacity(isHovering ? 0.7 : 1)
                )
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
