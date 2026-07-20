//
//  PracticeSummaryView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct PracticeSummaryView: View {
    
    // MARK: - Properties
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            SectionHeaderView(
                title: "학습 결과",
                actionTitle: "홈으로 이동"
            ) {
                // FIXME: - 액션 주입
                print("홈으로 이동 버튼 클릭")
            }

            practiceSummaryScrollView
                .padding(.vertical, 30)
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
        VStack(spacing: 0) {
            HStack {
                Text("2026.07.08")
                    .padding(.trailing, 42)
                
                Text("IT • 개발")
                    .padding(.trailing, 42)
                
                Text("자기소개 • 직무 역량")
                    .padding(.trailing, 42)

                Text("6문항")
                
                Spacer()
                
                PushButton(
                    title: "􀧵 메모 보기",
                    type: .neutral,
                    size: .small
                ) {
                    print("메모 보기 버튼 탭")
                }
            }
            .padding(.bottom, 34)
            
            Divider()
                .padding(.bottom, 30)
        }
    }
}
