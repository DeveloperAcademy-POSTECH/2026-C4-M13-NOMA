//
//  CorrectionFeedbackCardView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct CorrectionFeedbackCardView: View {
    
    // MARK: - Properties
    
    let originalText: String
    let correctedText: String
    let explanation: String
    var onListenTapped: () -> Void = {}
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            correctionTextSection
            
            repeatAfterMeSection
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.accentColorBackground.opacity(0.44))
        )
    }
}

// MARK: - SubViews

extension CorrectionFeedbackCardView {
    private var correctionTextSection: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(originalText)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .strikethrough()
                    .accessibilityLabel("교정 전 문장, \(originalText)")

                correctedSentenceRow

                Text("→ \(explanation)")
                    .font(.system(size: 13, weight: .regular))
                    .padding(.bottom, 12)
                    .accessibilityLabel("교정 이유, \(explanation)")
            }

            Spacer()
        }
    }
    
    private var correctedSentenceRow: some View {
        HStack(spacing: 8) {
            Text(correctedText)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.foreground)
                .accessibilityLabel("교정 후 문장, \(correctedText)")

            Button(action: onListenTapped) {
                Image(systemName: "speaker.wave.2")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("교정 문장 듣기")
            .accessibilityHint("교정된 문장을 음성으로 재생합니다")
        }
    }

    // FIXME: - 버튼에 액션 주입
    
    private var repeatAfterMeSection: some View {
        HStack(spacing: 0) {
            PushButton(
                title: "􀊰 따라 말하기",
                type: .default,
                size: .small
            ) {
                print("따라 말하기 버튼 탭")
            }
            .accessibilityLabel("따라 말하기")
            .accessibilityHint("교정된 문장을 따라 말하는 연습을 시작합니다")
            .padding(.trailing, 8)

            Button {
                print("재생 버튼 탭")
            } label: {
                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("녹음 재생")
            .accessibilityHint("따라 말한 녹음을 재생합니다")
            .padding(.horizontal, 16)

            Capsule()
                .fill(.tertiary)
                .frame(width: 160, height: 6)
                .accessibilityHidden(true)
        }
    }
}
