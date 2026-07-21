//
//  PracticeSummaryView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct PracticeSummaryView: View {
    
    // MARK: - Properties
    
    @Environment(AppRouter.self) private var router

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
                
                Divider()
                    .padding(.bottom, 30)
                
                // FIXME: - 데이터 주입
                
                OverallFeedbackCardView(
                    feedbackText: "전반적으로 격식체 어미가 사용되지 않았습니다.\n다음 학습에서는 '-해요' 대신 '-합니다'를 의식적으로 사용해 보십시오."
                )
                .padding(.bottom, 30)
                
                Text("스크립트")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 20)
                
                QuestionAnswerSectionView(
                    question: "Q1. 자기소개를 해주십시오.",
                    answerText: "안녕하십니까, 저는 지원자 셀리나 입니다.",
                    correction: .init(
                        originalText: "스페인에서 왔고 한국에서 컴퓨터공학을 전공했어요.",
                        correctedText: "스페인에서 왔고 한국에서 컴퓨터공학을 전공했습니다.",
                        explanation: "'-어요'는 비격식체 어미입니다. 이력을 설명할 때는 '-습니다' 체를 사용해야 합니다."
                    )
                )
            }
            .padding(.bottom, 34)
        }
    }
    
    private var practiceSummaryInfoSection: some View {
        HStack {
            Text("2026.07.08")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.trailing, 42)
            
            Text("IT • 개발")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.trailing, 42)
            
            Text("자기소개 • 직무 역량")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.trailing, 42)

            Text("6문항")
                .font(.body)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            PushButton(
                title: "􀧵 메모 보기",
                type: .neutral,
                size: .small
            ) {
                print("메모 보기 버튼 탭")
            }
        }
    }
}
