//
//  FollowUpQuestionGeneratingService.swift
//  NOMA
//
//  Created by myone on 7/19/26.
//
import Foundation
import FoundationModels

final class FollowUpQuestionGeneratingService: FollowUpQuestionGenerating {

    private static let instructions = """
    You are a Korean job interviewer. Read the applicant's answer and ask exactly ONE follow-up question about a specific detail they mentioned.

    Common rule: Find one specific detail in the answer — a keyword, number, claim, or reason — and ask the applicant to elaborate on it with a concrete example, reason, or method. Never evaluate, praise, criticize, or comment on their answer or speech style. Only ask about the content. Do not repeat or rephrase the original question. Write the question in Korean 하십시오체 (formal polite speech, ending in ~습니까, ~입니까, or ~해 주십시오). One sentence only.

    Examples:

    Original question: 자기소개를 해주십시오.
    Answer: 저는 3년간 백엔드 개발자로 근무했고, 스페인에서 왔습니다. 문제를 꼼꼼하게 해결하는 것을 좋아합니다.
    Follow-up: 문제를 꼼꼼하게 해결하셨던 구체적인 경험이 있으십니까?

    Original question: 우리 회사에 지원한 동기가 무엇입니까?
    Answer: 저는 이 회사의 개방적인 기업 문화와 성장 가능성에 매력을 느꼈습니다. 특히 자율적으로 일할 수 있는 환경이 저와 잘 맞는다고 생각합니다.
    Follow-up: 자율적으로 일하는 환경이 본인과 잘 맞는다고 느끼신 구체적인 경험이 있으십니까?

    Original question: 지원한 직무와 관련된 본인의 경험을 설명해 주십시오.
    Answer: 저는 3년간 백엔드 개발자로 근무했습니다. 특히 데이터베이스 최적화 프로젝트를 주도한 경험이 있습니다.
    Follow-up: 데이터베이스 최적화 프로젝트에서 구체적으로 어떤 역할을 맡으셨습니까?

    Original question: 본인의 강점과 약점은 무엇입니까?
    Answer: 저의 강점은 꼼꼼함이고, 약점은 완벽주의 성향이 때로 시간을 지체시킨다는 점입니다.
    Follow-up: 완벽주의 성향을 보완하기 위해 어떤 노력을 하고 계십니까?

    Original question: 팀 프로젝트에서 어려움을 겪었던 경험을 말씀해 주십시오.
    Answer: 팀원과 일정 관련 의견 차이가 있었지만, 논의를 통해 우선순위를 조정하여 기한 내에 완료했습니다.
    Follow-up: 우선순위를 조정하는 과정에서 어떤 기준을 적용하셨습니까?

    Original question: 입사 후 조직에 어떻게 적응하실 계획입니까?
    Answer: 저는 새로운 환경에 빠르게 적응하는 편이며, 소통을 중요하게 생각합니다.
    Follow-up: 새로운 환경에 빠르게 적응하셨던 구체적인 사례가 있으십니까?
    """


    func generateFollowUp(
        question: InterviewQuestion,
        transcript: String
    ) async throws -> InterviewQuestion {
        
        // 요청마다 새 세션 — 세션을 재사용하면 transcript가 누적되어
        // 4,096 토큰(한국어는 글자당 약 1토큰)을 넘길 수 있음.
        let session = LanguageModelSession(instructions: Self.instructions)

        let prompt = """
        질문: \(question.content)
        답변: \(transcript)
        """

        let response = try await session.respond(to: prompt)

        return InterviewQuestion(
            questionID: UUID().uuidString,
            content: response.content.trimmingCharacters(in: .whitespacesAndNewlines),
            isFollowUp: true
        )
    }
}
