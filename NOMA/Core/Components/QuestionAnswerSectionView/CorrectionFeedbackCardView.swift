//
//  CorrectionFeedbackCardView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import Foundation
import SwiftUI

struct CorrectionFeedbackCardView: View {
    
    // MARK: - Properties
    
    let originalText: String
    let correctedText: String
    let explanation: String
    var sentencePracticeState: SentencePracticeRecordState?
    var isSentencePracticeEnabled: Bool = false
    var isSentencePracticeRecording: Bool = false
    var isSentencePracticePlaying: Bool = false
    var onListenTapped: () -> Void = { /* no-op */ }
    var onSentencePracticeRecordingTapped: () -> Void = { /* no-op */ }
    var onSentencePracticePlaybackTapped: () -> Void = { /* no-op */ }
    
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

            Button {
                onListenTapped()
            } label: {
                Image(systemName: "speaker.wave.2")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("교정 문장 듣기")
        }
    }
    
    private var repeatAfterMeSection: some View {
        HStack(spacing: 0) {
            PushButton(
                title: recordingButtonTitle,
                type: .default,
                size: .small
            ) {
                onSentencePracticeRecordingTapped()
            }
            .frame(width: 128, height: 24)
            .padding(.trailing, 8)
            .disabled(!isRecordingButtonEnabled)
            .accessibilityLabel(recordingAccessibilityLabel)

            Button {
                onSentencePracticePlaybackTapped()
            } label: {
                Image(systemName: playbackIconName)
                    .font(.title3)
                    .foregroundStyle(playbackButtonColor)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .disabled(!isPlaybackButtonEnabled)
            .accessibilityLabel(playbackAccessibilityLabel)
            .padding(.horizontal, 16)

            playbackProgressBar
        }
    }

    private var playbackProgressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.tertiary.opacity(0.35))

                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: proxy.size.width * playbackProgress)
            }
        }
        .frame(width: 160, height: 6)
        .accessibilityHidden(true)
    }

    private var recordingButtonTitle: String {
        guard isSentencePracticeRecording else { return "􀊰 따라 말하기" }

        return "● 녹음 중 \(formattedTime(sentencePracticeState?.recordingDuration ?? 0))"
    }

    private var playbackIconName: String {
        isSentencePracticePlaying
            ? "pause.fill"
            : "play.fill"
    }

    private var playbackButtonColor: Color {
        isPlaybackButtonEnabled
            ? .secondary
            : .secondary.opacity(0.5)
    }

    private var isRecordingButtonEnabled: Bool {
        isSentencePracticeEnabled && !isSentencePracticePlaying
    }

    private var isPlaybackButtonEnabled: Bool {
        isSentencePracticeEnabled
            && !isSentencePracticeRecording
            && (sentencePracticeState?.hasRecordedAudio ?? false)
    }

    private var playbackProgress: CGFloat {
        guard let sentencePracticeState,
              sentencePracticeState.playbackDuration > 0 else { return 0 }

        return CGFloat(min(
            max(sentencePracticeState.playbackCurrentTime / sentencePracticeState.playbackDuration, 0),
            1
        ))
    }

    private var recordingAccessibilityLabel: String {
        isSentencePracticeRecording
            ? "따라 말하기 녹음 중, 다시 누르면 종료"
            : "따라 말하기 녹음 시작"
    }

    private var playbackAccessibilityLabel: String {
        isSentencePracticePlaying
            ? "따라 말하기 녹음 일시정지"
            : "따라 말하기 녹음 재생"
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%01d:%02d", minutes, seconds)
    }
}
