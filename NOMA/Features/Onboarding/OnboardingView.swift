//
//  OnboardingView.swift
//  NOMA
//
//  Created by 이은지 on 7/19/26.
//

import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Properties

    @State private var appleIntelligenceStatus = AppleIntelligenceStatus()
    @Environment(AppRouter.self) private var router
    @Environment(\.controlActiveState) private var controlActiveState

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            iconBadgeView
                .padding(.bottom, 22)
            
            headlineView
                .padding(.bottom, 16)
            
            descriptionView
                .padding(.bottom, 60)

            actionButtons
                .padding(.bottom, 13)
            
            settingsHintView
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .task {
            appleIntelligenceStatus.refresh()
        }
        .onChange(of: controlActiveState) { _, newState in
            if newState != .inactive {
                appleIntelligenceStatus.refresh()
            }
        }
    }
    
    // MARK: - Functions
    
    private func openAppleIntelligenceSettings() {
        guard let url = SystemSettingsURL.appleIntelligenceAndSiri else { return }
        
        NSWorkspace.shared.open(url)
    }
}

// MARK: - Subviews

extension OnboardingView {
    private var iconBadgeView: some View {
        Image(systemName: "apple.intelligence")
            .font(.system(size: 40))
            .foregroundStyle(.primary)
    }
    
    private var headlineView: some View {
        Text("Apple Intelligence를 켜주십시오")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }
    
    private var descriptionView: some View {
        Text("학습하기 기능은 Apple Intelligence로 목소리를 분석합니다.\n켜지 않으면 사용할 수 없습니다.")
            .font(.title2)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            CapsuleButton(
                title: "시스템 설정 열기",
                capsuleButtonType: .secondary
            ) {
                openAppleIntelligenceSettings()
            }
            .frame(
                width: 200,
                height: 42
            )

            CapsuleButton(
                title: "시작하기",
                capsuleButtonType: .primary
            ) {
                router.push(.home)
            }
            .frame(
                width: 200,
                height: 42
            )
            .disabled(!appleIntelligenceStatus.isEnabled)
        }
    }
    
    private var settingsHintView: some View {
        Text("\(boldPrefix)에서 켤 수 있습니다.")
            .font(.title3)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }

    private var boldPrefix: Text {
        Text("[시스템 설정 > Apple Intelligence 및 Siri]")
            .fontWeight(.semibold)
    }
}
