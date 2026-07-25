//
//  PermissionView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct PermissionView: View {

    // MARK: - Properties
    
    @Environment(AppRouter.self) private var router
    @Environment(\.controlActiveState) private var controlActiveState
    @State private var microphonePermissionStatus = MicrophonePermissionStatus()
    
    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            headlineView

            descriptionView
                .padding(.bottom, 44)

            microphonePermissionCardView
                .padding(.bottom, 44)

            actionButtons

            returnHomeButton
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .task {
            microphonePermissionStatus.refresh()
        }
        .onChange(of: controlActiveState) { _, newState in
            if newState != .inactive {
                microphonePermissionStatus.refresh()
            }
        }
    }
}

// MARK: - Subviews

extension PermissionView {
    private var headlineView: some View {
        Text("마이크 접근 권한")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
    }
    
    private var descriptionView: some View {
        Text("원활한 학습을 위해 마이크 접근 권한 허용이 필요합니다.\n권한을 허용하지 않으실 경우, 격식체 학습 기능을 이용하실 수 없습니다.")
            .font(.title2)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }
    
    private var microphonePermissionCardView: some View {
        VStack(spacing: 0) {
            microphoneIconView
                .padding(.bottom, 8)
            
            microphoneNameView
                .padding(.bottom, 20)
            
            microphoneDescriptionView
                .padding(.bottom, 20)
            
            microphonePermissionStatusView
        }
        .padding(30)
        .background(
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous
            )
            .fill(.regularMaterial.opacity(0.2))
        )
    }
    
    private var microphoneIconView: some View {
        Image(systemName: "microphone")
            .font(.title2)
            .foregroundStyle(.primary)
    }
    
    private var microphoneNameView: some View {
        Text("마이크")
            .font(.title2)
            .foregroundStyle(.primary)
    }
    
    private var microphoneDescriptionView: some View {
        Text("음성 답변을 기록하고 발화를 분석하기 위해\n권한 허용이 필요합니다.")
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    
    private var microphonePermissionStatusView: some View {
        Text(
            microphonePermissionStatus.isGranted
            ? "권한 허용됨"
            : "권한 허용되지 않음"
        )
        .font(.callout)
        .foregroundStyle(
            microphonePermissionStatus.isGranted
            ? .green
            : .red
        )
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            CapsuleButton(
                title: "권한 허용하기",
                capsuleButtonType: .secondary
            ) {
                microphonePermissionStatus.requestAccess()
            }
            .frame(
                width: 200,
                height: 42
            )

            CapsuleButton(
                title: "시작하기",
                capsuleButtonType: .primary
            ) {
                router.push(.interviewPractice)
            }
            .frame(
                width: 200,
                height: 42
            )
            .disabled(!microphonePermissionStatus.isGranted)
        }
    }
    
    private var returnHomeButton: some View {
        PushButton(
            title: "홈으로 돌아가기",
            type: .borderless,
            size: .small
        ) {
            router.popToRoot()
        }
    }
}
