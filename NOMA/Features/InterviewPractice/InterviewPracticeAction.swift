//
//  InterviewPracticeAction.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import Foundation

enum InterviewPracticeAction {
    case viewAppeared // InterviewPracticeView가 화면에 나타났을 때
    case viewDisappeared // 화면이 사라질 때
    case readyCountdownFinished // ready 안내 문구가 3초간 노출된 뒤 질문 시작 시점이 됐을 때
    case questionSpeechFinished // TTS가 질문을 다 끝냈을 때
    case transcriptUpdated(String) // 실시간 STT 결과가 갱신됐을 때
    case finishAnswering // 사용자가 "답변 완료" 버튼을 눌렀을 때
    case recordingTimeLimitReached // 3분 타이머가 다 됐을 때 (버튼 안 눌러도 강제 종료)
    case retryCurrentAnswer // 사용자가 "다시 답변하기" 버튼을 눌렀을 때
    case moveToNextQuestion // 사용자가 "다음 질문" 버튼을 눌렀을 때
    case captionsChanged(Bool)// 자막 토글을 켜거나 껐을 때
    case exitRequested // "학습 종료" 버튼을 눌렀을 때 -> 확인 Alert
    case exitConfirmed // 확인창에서 "나가기"를 눌렀을 때
    case exitCancelled // 확인창에서 "취소"를 눌렀을 때
}
