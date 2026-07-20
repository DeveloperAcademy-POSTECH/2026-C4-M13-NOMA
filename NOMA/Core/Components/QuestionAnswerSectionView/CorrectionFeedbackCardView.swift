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

                correctedSentenceRow

                Text("→ \(explanation)")
                    .font(.system(size: 13, weight: .regular))
                    .padding(.bottom, 12)
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

            Button {
                print("듣기 버튼 탭")
            } label: {
                Image(systemName: "speaker.wave.2")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
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
            .padding(.trailing, 8)

            Button {
                print("재생 버튼 탭")
            } label: {
                Image(systemName: "play.fill")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)

            Capsule()
                .fill(.tertiary)
                .frame(width: 160, height: 6)
        }
    }
}
