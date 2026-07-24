//
//  FollowUpQuestionOutput.swift
//  NOMA
//
//  Created by 이은지 on 7/23/26.
//

import FoundationModels

private enum Guides {
    nonisolated static let followUpQuestion = """
        Exactly one new Korean follow-up question in 하십시오체, asking about a specific detail \
        from the applicant's answer. Must not repeat, rephrase, or quote the applicant's answer \
        or the original question verbatim
        """
}

@Generable
struct FollowUpQuestionOutput {
    @Guide(description: Guides.followUpQuestion)
    let followUpQuestion: String
}
