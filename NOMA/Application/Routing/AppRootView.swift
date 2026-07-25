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
    @State private var appleIntelligenceStatus = AppleIntelligenceStatus()

    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .onboarding:
                        OnboardingView()
                        
                    case .permission:
                        PermissionView()
                        
                    case .interviewPractice:
                        InterviewPracticeView(store: Self.makeInterviewPracticeStore())
                        
                    case .answerAnalysisLoading(let id):
                        AnswerAnalysisLoadingView(recordID: id)
                        
                    case .practiceSummary(let id):
                        PracticeSummaryView(recordID: id)
                        
                    case .learningHistory:
                        LearningHistoryView()
                    }
                }
        }
        .task {
            appleIntelligenceStatus.refresh()
            if !appleIntelligenceStatus.isEnabled {
                router.push(.onboarding)
            }
        }
        .environment(appleIntelligenceStatus)
        .environment(router)
    }
}

// MARK: - Factory Method

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
