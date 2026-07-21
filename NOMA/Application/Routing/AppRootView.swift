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
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .onboarding: OnboardingView()
                    case .home: HomeView()
                    case .permission: PermissionView()
                    case .interviewPractice: InterviewPracticeView()
                    case .answerAnalysisLoading: AnswerAnalysisLoadingView()
                    case .practiceSummary: PracticeSummaryView()
                    case .learningHistory: LearningHistoryView()
                    }
                }
        }
        .environment(router)
    }
}
