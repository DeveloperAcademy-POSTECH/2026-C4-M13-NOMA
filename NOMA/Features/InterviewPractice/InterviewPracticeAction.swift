//
//  InterviewPracticeAction.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import Foundation

enum InterviewPracticeAction {
    case viewAppeared                                   // InterviewPracticeView가 화면에 나타났을 때
    case viewDisappeared                                // 화면이 사라질 때
    case readyCountdownFinished                         // ready 안내 문구 노출 뒤 질문 시작
    case questionSpeechFinished                         // TTS가 질문을 다 끝냈을 때
    case transcriptUpdated(text: String, isFinal: Bool) // 실시간 STT 결과가 갱신됐을 때
    case toggleFeedbackVisibility
    case readyCountdownFinished                         // ready 안내 문구가 3초간 노출된 뒤 질문 시작 시점이 됐을 때
    case questionSpeechFinished                         // TTS가 질문을 다 끝냈을 때
    case recordingStarted                               // 실제 마이크 녹음이 시작됐을 때 (경과 시간 타이머와 답변 완료 버튼 활성화 기준 시점)
    case transcriptUpdated(text: String, isFinal: Bool) // 실시간 STT 결과가 갱신됐을 때 (isFinal이면 확정 문장으로 누적)
    case finishAnswering                                // 사용자가 "답변 완료" 버튼을 눌렀을 때
    case recordingTimeLimitReached                      // 3분 타이머가 다 됐을 때
    case sentenceFeedbackArrived(index: Int, originalText: String, feedback: SentenceFeedback?)
    case correctedSentencePlaybackRequested(String)     // 교정 카드의 스피커 버튼을 눌렀을 때
    case sentencePracticeRecordingButtonTapped(index: Int)
    case sentencePracticeRecordingDurationUpdated(index: Int, duration: TimeInterval)
    case sentencePracticeRecordingFinished(index: Int, recordedAudio: RecordedAudio)
    case sentencePracticePlaybackButtonTapped(index: Int)
    case sentencePracticePlaybackPaused(index: Int, currentTime: TimeInterval)
    case sentencePracticePlaybackProgressRequested(index: Int)
    case sentencePracticePlaybackProgressUpdated(index: Int, currentTime: TimeInterval)
    case sentencePracticePlaybackFinished(index: Int)
    case sentencePracticeFailed(index: Int)
    case overallFeedbackGenerated(String)                // 전체적인 피드백 생성이 끝났을 때
    case followUpQuestionGenerated(InterviewQuestion?)   // 꼬리질문 생성 완료
    case retryCurrentAnswer                             // 사용자가 "다시 답변하기" 버튼을 눌렀을 때
    case moveToNextQuestion                             // 사용자가 "다음 질문" 버튼을 눌렀을 때
    case captionsChanged(Bool)                          // 자막 토글을 켜거나 껐을 때
    case exitRequested                                  // "학습 종료" 버튼을 눌렀을 때 -> 확인 Alert
    case exitConfirmed                                  // 확인창에서 "나가기"를 눌렀을 때
    case exitCancelled                                  // 확인창에서 "취소"를 눌렀을 때
}
