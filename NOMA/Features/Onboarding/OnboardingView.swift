//
//  OnboardingView.swift
//  NOMA
//
//  Created by 이은지 on 7/19/26.
//

import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Properties
    
    
    // MARK: - Initializer

    
    // MARK: - Body
    
    var body: some View {
        Image(systemName: "apple.intelligence")
            .font(.system(size: 40))
            .foregroundStyle(.primary)
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(Color(nsColor: .tertiarySystemFill))
            )
        
        Text("Apple Intelligence를 켜주십시오")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
        
        Text("학습하기 기능은 Apple Intelligence 기반의 음성 분석을 사용합니다.\n켜지 않으면 학습하기 기능을 사용할 수 없습니다.")
            .font(.title2)
            .foregroundStyle(.primary)

        CapsuleButton(
            title: "시스템 설정 열기",
            capsuleButtonType: .secondary
        ) {
            print("시스템 설정 열기")
        }
        
        CapsuleButton(
            title: "시작하기",
            capsuleButtonType: .primary
        ) {
            print("시스템 설정 열기")
        }
        
        Text("[시스템 설정 > Apple Intelligence 및 Siri]에서 켤 수 있습니다.")
            .font(.title3)
            .foregroundStyle(.secondary)
    }
}
