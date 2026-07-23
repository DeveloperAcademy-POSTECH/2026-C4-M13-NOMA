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
    case readyCountdownFinished                         // ready 안내 문구가 3초간 노출된 뒤 질문 시작 시점이 됐을 때
    case questionSpeechFinished                         // TTS가 질문을 다 끝냈을 때
    case recordingStarted                               // 실제 마이크 녹음이 시작됐을 때 (경과 시간 타이머와 답변 완료 버튼 활성화 기준 시점)
    case transcriptUpdated(text: String, isFinal: Bool) // 실시간 STT 결과가 갱신됐을 때 (isFinal이면 확정 문장으로 누적)
    case finishAnswering                                // 사용자가 "답변 완료" 버튼을 눌렀을 때
    case recordingTimeLimitReached                      // 3분 타이머가 다 됐을 때 (버튼 안 눌러도 강제 종료)
    case sentenceFeedbackArrived(index: Int, originalText: String, feedback: SentenceFeedback?) // 확정 문장 하나의 피드백 결과가 도착했을 때 (nil = 교정 불필요)
    case correctedSentencePlaybackRequested(String)     // 교정 카드의 스피커 버튼을 눌렀을 때
    case overallFeedbackGenerated(String)                // 전체적인 피드백 생성이 끝났을 때 (빈 문자열이면 특이사항 없음)
    case followUpQuestionGenerated(InterviewQuestion?)   // 방금 답변한 질문에 대한 꼬리질문 생성이 끝났을 때 (nil = 생성 대상 아님/실패)
    case retryCurrentAnswer                             // 사용자가 "다시 답변하기" 버튼을 눌렀을 때
    case moveToNextQuestion                             // 사용자가 "다음 질문" 버튼을 눌렀을 때
    case captionsChanged(Bool)                          // 자막 토글을 켜거나 껐을 때
    case exitRequested                                  // "학습 종료" 버튼을 눌렀을 때 -> 확인 Alert
    case exitConfirmed                                  // 확인창에서 "나가기"를 눌렀을 때
    case exitCancelled                                  // 확인창에서 "취소"를 눌렀을 때
}
