//
//  PermissionView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct PermissionView: View {
    
    // MARK: - Properties

    // MARK: - Body

    var body: some View {
        titleView
        
        subtitleView
        
        microphonePermissionCard
        
        actionButtons

        returnHomeButton
    }
}

// MARK: - SubViews

extension PermissionView {
    private var titleView: some View {
        Text("마이크 접근 권한")
            .font(
                .system(
                    size: 22,
                    weight: .bold
                )
            )
            .foregroundStyle(.primary)
    }
    
    private var subtitleView: some View {
        Text("원활한 학습을 위해 마이크 접근 권한 허용이 필요합니다.\n권한을 허용하지 않으실 경우, 격식체 학습 기능을 이용하실 수 없습니다.")
            .font(.title2)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }
    
    private var microphonePermissionCard: some View {
        VStack {
            microphoneIconView
            
            microphoneNameText
            
            microphoneDescriptionText
            
            permissionStatusText
        }
        .background(
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous
            )
            .fill(.regularMaterial)
        )
        .frame(
            width: 300,
            height: 211
        )
    }
    
    private var microphoneIconView: some View {
        Image(systemName: "microphone")
            .font(.title2)
            .foregroundStyle(.primary)
    }
    
    private var microphoneNameText: some View {
        Text("마이크")
            .font(.title2)
            .foregroundStyle(.primary)
    }
    
    private var microphoneDescriptionText: some View {
        Text("음성 답변을 기록하고 발화를 분석하기 위해\n권한 허용이 필요합니다.")
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    
    private var permissionStatusText: some View {
        Text("권한 허용되지 않음")
            .font(.callout)
            .foregroundStyle(.red)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(
                    cornerRadius: 4,
                    style: .continuous
                )
                .fill(.white)
            )
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            CapsuleButton(
                title: "권한 허용하기",
                capsuleButtonType: .secondary
            ) {
                // 액션
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
            // 액션
        }
    }
    
    private var returnHomeButton: some View {
        PushButton(
            title: "홈으로 돌아가기",
            type: .borderless,
            size: .small
        ) {
            // FIXME: - 액션 주입
            print("홈으로 돌아가기")
        }
    }
}
