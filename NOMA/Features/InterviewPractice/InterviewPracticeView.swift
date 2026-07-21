//
//  InterviewPracticeView.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import SwiftUI

import Lottie

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

    private var displayedQuestionNumber: Int {
        store.state.phase == .ready ? 0 : currentQuestionNumber
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("문제 \(displayedQuestionNumber)/\(totalQuestions)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            ProgressView(
                value: Double(displayedQuestionNumber),
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

    private var currentQuestionTitle: String {
        guard let content = store.state.session.currentQuestion?.content else { return "" }
        return "Q\(currentQuestionNumber). \(content)"
    }

    private var displayedAnswerSentences: [AnswerSentence] {
        var sentences = store.state.answerSentences

        sentences.append(
            contentsOf: AnswerSentence.splitIntoSentences(store.state.volatileTranscript)
                .map { AnswerSentence(text: $0) }
        )

        return sentences
    }

    private var elapsedTimeText: String {
        let totalSeconds = Int(store.state.elapsedRecordingDuration.components.seconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var interviewerPane: some View {
        VStack(spacing: 0) {
            Spacer()

            if let currentLottieAnimationName {
                LottieView(animation: .named(currentLottieAnimationName))
                    .looping()
                    .frame(width: 385)
                    .id(currentLottieAnimationName)
                    .padding(.top, 116)
                    .padding(.bottom, 72)
            }

            Text(questionPromptText)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(
                    .bottom,
                    currentLottieAnimationName != nil
                    ? 106
                    : 288
                )

            bottomControls
                .padding(.bottom, 112)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private var currentLottieAnimationName: String? {
        switch store.state.phase {
        case .ready:
            return nil
            
        case .askingQuestion:
            return "Question playing"
            
        case .recording:
            return "UserSpeaking"
            
        default:
            return "Standby"
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 18) {
            Text(elapsedTimeText)
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
            .disabled(!store.state.canFinishAnswer)
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
                .padding(.vertical, 16)

            if store.state.phase != .ready {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(
                            alignment: .leading,
                            spacing: 0,
                            pinnedViews: [.sectionHeaders]
                        ) {
                            QuestionAnswerSectionView(
                                question: currentQuestionTitle,
                                sentences: displayedAnswerSentences,
                                onListenTapped: { correctedText in
                                    store.send(.correctedSentencePlaybackRequested(correctedText))
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)

                        Color.clear
                            .frame(height: 1)
                            .id("transcriptBottom")
                    }
                    .onChange(of: store.state.liveTranscript) {
                        withAnimation(.easeOut(duration: 0.15)) {
                            proxy.scrollTo("transcriptBottom", anchor: .bottom)
                        }
                    }
                }

                if let overallFeedbackText = store.state.overallFeedbackText, !overallFeedbackText.isEmpty {
                    Divider()

                    OverallFeedbackCardView(feedbackText: overallFeedbackText)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
            } else {
                Spacer(minLength: 0)
            }

            feedbackBottomButtons
        }
        .frame(width: 650)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var isAwaitingQuestion: Bool {
        store.state.phase == .ready
            || store.state.phase == .askingQuestion
            || store.state.phase == .generatingFeedback
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
            .disabled(isAwaitingQuestion)

            CapsuleButton(
                title: "다음 질문",
                capsuleButtonType: .primary
            ) {
                store.send(.moveToNextQuestion)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .disabled(isAwaitingQuestion)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 50)
    }
}
