//
//  AppRootView.swift
//  NOMA
//
//  Created by 이은지 on 7/21/26.
//

import SwiftUI

struct AppRootView: View {
    
    // MARK: - Properties
    
    @State private var router = AppRouter()

    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $router.path) {
            // FIXME: - RootView Home 화면으로 변경 예정
            OnboardingView()
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: AppRoute.self) { route in
                    Group {
                        switch route {
                        case .onboarding: OnboardingView()
                        case .home: HomeView()
                        case .permission: PermissionView()
                        case .interviewPractice: InterviewPracticeView(store: AppRootView.makeInterviewPracticeStore())
                        case .answerAnalysisLoading: AnswerAnalysisLoadingView()
                        case .practiceSummary: PracticeSummaryView()
                        case .learningHistory: LearningHistoryView()
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                }
        }
        .environment(router)
    }
}

// MARK: - Factory

extension AppRootView {
    private static func makeInterviewPracticeStore() -> InterviewPracticeStore {
        InterviewPracticeStore(
            session: .makeInitial(),
            reducer: InterviewPracticeReducer(
                audioRecorder: AVAudioRecordingService(),
                audioPlayer: AVAudioPlayerService(),
                questionSpeaker: AVSpeechSynthesizerService(),
                speechTranscribing: SpeechTranscriptionService(),
                interviewFeedbackGenerating: FoundationModelsFeedbackService(),
                followUpQuestionGenerating: FollowUpQuestionGeneratingService()
            )
        )
    }
}
