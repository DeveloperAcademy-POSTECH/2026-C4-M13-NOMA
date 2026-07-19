//
//  OnboardingView.swift
//  NOMA
//
//  Created by 이은지 on 7/19/26.
//

import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Properties

    @State private var isAppleIntelligenceEnabled: Bool = true
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            iconBadgeView
                .disabled(!isAppleIntelligenceEnabled)
            
            headlineView
            
            descriptionView
                .padding(.bottom, 44)

            actionButtons
            
            settingsHintView
        }
    }
}

// MARK: - Subviews

extension OnboardingView {
    private var iconBadgeView: some View {
        Image(systemName: "apple.intelligence")
            .font(.system(size: 40))
            .foregroundStyle(iconForegroundColor)
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconBackgroundColor)
            )
    }

    private var iconForegroundColor: Color {
        isAppleIntelligenceEnabled
            ? .accentColor
            : Color(nsColor: .labelColor)
    }

    private var iconBackgroundColor: Color {
        isAppleIntelligenceEnabled
            ? .accentColorBackground
            : Color(nsColor: .tertiarySystemFill)
    }
    
    private var headlineView: some View {
        Text("Apple Intelligence를 켜주십시오")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }
    
    private var descriptionView: some View {
        Text("학습하기 기능은 Apple Intelligence 기반의 음성 분석을 사용합니다.\n켜지 않으면 학습하기 기능을 사용할 수 없습니다.")
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
                print("시스템 설정 열기")
            }
            .frame(
                width: 200,
                height: 42
            )

            CapsuleButton(
                title: "시작하기",
                capsuleButtonType: .primary
            ) {
                print("시작하기")
            }
            .frame(
                width: 200,
                height: 42
            )
            .disabled(!isAppleIntelligenceEnabled)
        }
    }
    
    private var settingsHintView: some View {
        Text("[시스템 설정 > Apple Intelligence 및 Siri]에서 켤 수 있습니다.")
            .font(.title3)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}
