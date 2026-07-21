//
//  PracticePhase.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import Foundation

enum PracticePhase {
    case ready                      // 화면 진입 전 초기 상태
    case askingQuestion             // 면접관이 질문을 낭독 중
    case recording                  // 사용자 답변 녹음 중
    case transcribing               // STT로 답변을 텍스트로 변환 중
    case generatingFeedback         // FM이 격식체 피드백 생성 중
    case reviewing                  // 피드백을 화면에 보여주는 중 (다시 답변 / 다음 질문 대기)
    case generatingFollowUpQuestion // FM이 꼬리질문 생성 중
    case completed                  // 모든 질문 완료
}
