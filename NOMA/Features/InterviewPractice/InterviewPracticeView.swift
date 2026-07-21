//
//  InterviewPracticeView.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import SwiftUI

struct InterviewPracticeView: View {

    @Environment(\.openWindow) private var openWindow

    private let totalQuestions = 6
    @State private var currentQuestion = 1
    @State private var isFeedbackVisible = true

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 30)
                .frame(height: 78)

            Divider()

            HStack(spacing: 0) {
                interviewerPane

                if isFeedbackVisible {
                    Divider()
                    feedbackPanel
                }
            }
        }
        .frame(minWidth: 800, minHeight: 560)
    }
}

extension InterviewPracticeView {
    private var header: some View {
        HStack(spacing: 8) {
            Text("문제 \(currentQuestion)/\(totalQuestions)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            ProgressView(
                value: Double(currentQuestion),
                total: Double(totalQuestions)
            )
            .progressViewStyle(.linear)
            .frame(maxWidth: 300)

            Spacer()

            layoutToggleButtons

            PushButton(title: "학습 종료", type: .neutral, size: .medium) {
                // 홈으로 가기
            }
        }
    }
    
    private var layoutToggleButtons: some View {
        HStack(spacing: 4) {
            PushButton(title: "􀧵", type: .neutral, size: .medium) {
                openWindow(id: "memo")
            }
            PushButton(title: "􀏛", type: .neutral, size: .medium) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFeedbackVisible.toggle()
                }
            }
        }
    }
    
}

extension InterviewPracticeView {
    private var interviewerPane: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("잠시 후 문제가 시작됩니다.")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Spacer()

            bottomControls
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var bottomControls: some View {
        VStack(spacing: 18) {
            Text("00:00")
                .font(.body)
                .fontWeight(.thin)
                .foregroundStyle(.secondary)

            CapsuleButton(title: "답변 완료", capsuleButtonType: .primary) { }
                .frame(width: 120, height: 42)
                .disabled(true)
        }
    }
}

extension InterviewPracticeView {
    private var feedbackPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                
                Text("􀅂")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Text("피드백")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()

                HStack(spacing: 8) {
                    Button {
                        if currentQuestion > 1 { currentQuestion -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.medium)
                            .foregroundStyle(.accent)
                    }
                    .buttonStyle(.plain)

                    Text("\(currentQuestion)/\(totalQuestions)")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    Button {
                        if currentQuestion < totalQuestions { currentQuestion += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                            .fontWeight(.medium)
                            .foregroundStyle(.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)


            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
                .padding(20)
            }

            Divider()
            
            OverallFeedbackCardView(
                feedbackText: "일부 문장에서 격식체 어미가 사용되지 않았습니다.\n다음 답변에서는 '-해요' 대신 '-합니다'를 의식적으로 사용해 보십시오."
            )
            
            feedbackBottomButtons
        }
        .frame(width: 720)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var feedbackBottomButtons: some View {
        HStack(spacing: 12) {
            CapsuleButton(title: "다시 답변하기", capsuleButtonType: .secondary) { }
                .frame(maxWidth: .infinity)
                .frame(height: 44)

            CapsuleButton(title: "다음 질문", capsuleButtonType: .primary) { }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
