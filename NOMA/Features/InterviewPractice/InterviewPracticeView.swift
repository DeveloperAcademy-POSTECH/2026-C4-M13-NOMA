//
//  InterviewPracticeView.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import SwiftData
import SwiftUI

import Lottie

struct InterviewPracticeView: View {
    
    // MARK: - Properties
    
    @Environment(AppRouter.self) private var router
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext
    @Environment(MemoStore.self) private var memoStore
    
    let store: InterviewPracticeStore
    private let totalQuestions = 6
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.horizontal, 30)
                .frame(height: 78)
            
            Divider()
            
            HStack(spacing: 0) {
                interviewerPaneView

                if store.state.isFeedbackVisible {
                    Divider()
                        .transition(.opacity)

                    feedbackPanelView
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: store.state.isFeedbackVisible)
        }
        .onAppear {
            store.send(.viewAppeared)
            memoStore.text = ""
        }
        .onChange(of: store.state.phase) { _, newPhase in
            guard newPhase == .completed else { return }
            saveCompletedSession()
        }
        .alert(
            "정말 나가시겠습니까?",
            isPresented: isExitAlertPresented
        ) {
            Button("취소", role: .cancel) {
                store.send(.exitCancelled)
            }
            Button("나가기", role: .destructive) {
                store.send(.exitConfirmed)
                router.popToRoot()
            }
        } message: {
            Text("지금 화면을 벗어나시면 지금까지 진행된 면접 내용과 설정 정보는 저장되지 않습니다. 그래도 종료하시겠습니까?")
        }
    }
    
    // MARK: - Functions
    
    private func saveCompletedSession() {
        let record = PracticeRecord(
            memo: memoStore.text,
            questions: store.state.session.answers.enumerated().map { index, answer in
                QuestionRecord(
                    order: index,
                    questionContent: answer.question.content,
                    isFollowUp: answer.question.isFollowUp,
                    transcript: answer.transcript,
                    sentences: answer.sentences,
                    feedbackItems: answer.feedbackItems,
                    overallFeedback: answer.overallFeedback
                )
            }
        )
        modelContext.insert(record)
        try? modelContext.save()
        memoStore.text = ""
        router.push(.answerAnalysisLoading(record.persistentModelID))
    }
    
    private func handleListenTapped(_ correctedText: String) {
        store.send(.correctedSentencePlaybackRequested(correctedText))
    }

    private func handleSentencePracticeRecordingTapped(_ index: Int) {
        store.send(.sentencePracticeRecordingButtonTapped(index: index))
    }

    private func handleSentencePracticePlaybackTapped(_ index: Int) {
        store.send(.sentencePracticePlaybackButtonTapped(index: index))
    }
}

// MARK: - Subviews

extension InterviewPracticeView {
    private var headerView: some View {
        HStack(spacing: 0) {
            questionProgressView

            Spacer()

            headerActionButtons
        }
    }

    private var questionProgressView: some View {
        HStack(spacing: 16) {
            Text("문제 \(displayedQuestionNumber)/\(totalQuestions)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .accessibilityHidden(true)

            ProgressView(
                value: Double(displayedQuestionNumber),
                total: Double(totalQuestions)
            )
            .progressViewStyle(.linear)
            .frame(width: 400)
            .accessibilityLabel("문제 진행률")
            .accessibilityValue("\(displayedQuestionNumber) / \(totalQuestions)")
        }
    }

    private var headerActionButtons: some View {
        HStack(spacing: 16) {
            memoButton

            feedbackVisibilityToggle

            Divider()
                .frame(height: 20)

            exitButton
        }
    }

    private var memoButton: some View {
        PushButton(
            title: "􀧵 메모",
            type: .neutral,
            size: .medium
        ) {
            openWindow(id: "memo")
        }
        .accessibilityLabel("메모 열기")
    }

    private var feedbackVisibilityToggle: some View {
        HStack(spacing: 8) {
            Text("피드백 창")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)

            Toggle("", isOn: isFeedbackVisible)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(.accentColor)
        }
        .accessibilityLabel(store.state.isFeedbackVisible ? "피드백 숨기기" : "피드백 보이기")
    }

    private var exitButton: some View {
        PushButton(
            title: "학습 종료",
            type: .borderless,
            size: .medium
        ) {
            store.send(.exitRequested)
        }
    }

    private var interviewerPaneView: some View {
        VStack(spacing: 0) {
            interviewerLottieView
                .padding(.bottom, 28)
            
            questionPromptView
                .padding(.bottom, 46)
            
            elapsedTimeView
                .padding(.bottom, 18)

            finishAnsweringButton
                .padding(.bottom, 18)

            if !store.state.isFeedbackVisible {
                feedbackBottomButtons
                    .frame(
                        width: 400,
                        height: 42
                    )
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    @ViewBuilder
    private var interviewerLottieView: some View {
        if let currentLottieAnimationName {
            LottieView(animation: .named(currentLottieAnimationName))
                .resizable()
                .looping()
                .aspectRatio(contentMode: .fit)
                .frame(width: 385, height: 385)
                .id(currentLottieAnimationName)
                .accessibilityHidden(true)
        }
    }
    
    private var questionPromptView: some View {
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
            .padding(.horizontal, 20)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var elapsedTimeView: some View {
        Text(elapsedTimeText)
            .font(.body)
            .fontWeight(.thin)
            .foregroundStyle(.secondary)
            .accessibilityLabel("답변 시간")
            .accessibilityValue(elapsedTimeText)
    }

    private var finishAnsweringButton: some View {
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
        .accessibilityHint("현재 답변을 완료하고 피드백 확인으로 이동합니다.")
    }
    
    private var feedbackPanelView: some View {
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
                answerFeedbackScrollView

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

    private var answerFeedbackScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                answerSentencesSectionView
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
    }

    private var answerSentencesSectionView: some View {
        LazyVStack(
            alignment: .leading,
            spacing: 0
        ) {
            QuestionAnswerSectionView(
                question: currentQuestionTitle,
                sentences: displayedAnswerSentences,
                sentencePracticeRecords: store.state.sentencePracticeRecords,
                isSentencePracticeEnabled: store.state.isSentencePracticeEnabled,
                recordingSentencePracticeIndex: store.state.recordingSentencePracticeIndex,
                playingSentencePracticeIndex: store.state.playingSentencePracticeIndex,
                onListenTapped: handleListenTapped,
                onSentencePracticeRecordingTapped: handleSentencePracticeRecordingTapped,
                onSentencePracticePlaybackTapped: handleSentencePracticePlaybackTapped
            )
            .padding(.horizontal, 20)
        }
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
            .disabled(isAwaitingAnswerCompletion)

            CapsuleButton(
                title: isLastQuestion ? "학습 종료" : "다음 질문",
                capsuleButtonType: .primary
            ) {
                store.send(.moveToNextQuestion)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .disabled(isAwaitingAnswerCompletion)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 50)
    }
}

// MARK: - Derived State

extension InterviewPracticeView {
    private var currentQuestionNumber: Int {
        store.state.session.currentQuestionIndex + 1
    }

    private var displayedQuestionNumber: Int {
        switch store.state.phase {
        case .ready:
            return 0

        case .completed:
            return totalQuestions

        default:
            return min(currentQuestionNumber, totalQuestions)
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

    private var currentLottieAnimationName: String? {
        switch store.state.phase {
        case .ready:
            return nil
            
        case .askingQuestion:
            return "QuestionPlaying"
            
        case .recording:
            return "UserSpeaking"
            
        default:
            return "Standby"
        }
    }

    private var isAwaitingAnswerCompletion: Bool {
        store.state.phase != .reviewing
    }

    private var isLastQuestion: Bool {
        currentQuestionNumber >= totalQuestions
    }
}

// MARK: - Bindings

extension InterviewPracticeView {
    private var isExitAlertPresented: Binding<Bool> {
        Binding(
            get: { store.state.isExitConfirmationPresented },
            set: { isPresented in
                guard !isPresented else { return }
                store.send(.exitCancelled)
            }
        )
    }

    private var isFeedbackVisible: Binding<Bool> {
        Binding(
            get: { store.state.isFeedbackVisible },
            set: { newValue in store.send(.feedbackVisibilityChanged(newValue)) }
        )
    }
}
