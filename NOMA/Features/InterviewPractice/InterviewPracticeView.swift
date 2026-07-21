//
//  InterviewPracticeView.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import SwiftUI

struct InterviewPracticeView: View {

    // MARK: - Properties
    
    @Environment(AppRouter.self) private var router
    @Environment(\.openWindow) private var openWindow
    
    @State private var isFeedbackVisible = true

    let store: InterviewPracticeStore
    private let totalQuestions = 6

    // MARK: - Body

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
        .frame(
            minWidth: 800,
            minHeight: 560
        )
        .onAppear {
            store.send(.viewAppeared)
        }
    }
}

// MARK: - SubViews

extension InterviewPracticeView {
    private var currentQuestionNumber: Int {
        store.state.session.currentQuestionIndex + 1
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("문제 \(currentQuestionNumber)/\(totalQuestions)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            ProgressView(
                value: Double(currentQuestionNumber),
                total: Double(totalQuestions)
            )
            .progressViewStyle(.linear)
            .frame(maxWidth: 300)

            Spacer()

            layoutToggleButtons

            PushButton(
                title: "학습 종료",
                type: .default,
                size: .medium
            ) {
                router.push(.answerAnalysisLoading)
            }
        }
    }
    
    private var layoutToggleButtons: some View {
        HStack(spacing: 4) {
            PushButton(
                title: "􀧵",
                type: .neutral,
                size: .medium
            ) {
                openWindow(id: "memo")
            }
            
            PushButton(
                title: "􀏛",
                type: .neutral,
                size: .medium
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFeedbackVisible.toggle()
                }
            }
        }
    }
    
    private var questionPromptText: String {
        store.state.phase == .ready
            ? BaseInterviewQuestion.readyPromptText
            : store.state.session.currentQuestion?.content ?? ""
    }

    private var interviewerPane: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(questionPromptText)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 288)

            bottomControls
                .padding(.bottom, 112)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var bottomControls: some View {
        VStack(spacing: 18) {
            Text("00:00")
                .font(.body)
                .fontWeight(.thin)
                .foregroundStyle(.secondary)

            CapsuleButton(
                title: "답변 완료",
                capsuleButtonType: .primary
            ) {
                store.send(.finishAnswering)
            }
            .frame(
                width: 120,
                height: 42
            )
            .disabled(store.state.phase == .ready)
        }
    }
    
    private var feedbackPanel: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {
            Text("피드백")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            if store.state.phase != .ready {
                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {
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
                .padding(20)
            } else {
                Spacer(minLength: 0)
            }

            feedbackBottomButtons
        }
        .frame(width: 650)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var feedbackBottomButtons: some View {
        HStack(spacing: 12) {
            CapsuleButton(
                title: "다시 답변하기",
                capsuleButtonType: .secondary
            ) {
                store.send(.retryCurrentAnswer)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .disabled(store.state.phase == .ready)

            CapsuleButton(
                title: "다음 질문",
                capsuleButtonType: .primary
            ) {
                store.send(.moveToNextQuestion)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .disabled(store.state.phase == .ready)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
    }
}
