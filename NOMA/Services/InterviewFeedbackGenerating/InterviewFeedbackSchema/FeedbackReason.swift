//
//  FeedbackReason.swift
//  NOMA
//
//  Created by seokho on 7/21/26.
//

import FoundationModels

@Generable
enum FeedbackReason {
    case speechStyle
    case humbleForm
    case subjectHonorific
}

@Generable
struct Correction {
    @Guide(description: "The exact expression copied character-for-character from the input sentence")
    let originalExpression: String
    @Guide(description: "What originalExpression became in revisedSentence")
    let correctedExpression: String
    @Guide(description: "Which rule: speechStyle for 반말/해요체 → 합쇼체, humbleForm for 내가/나는 → 제가/저는, subjectHonorific for 이/가 → 께서")
    let reason: FeedbackReason
}

extension FeedbackReason {
    func explanation(from original: String, to corrected: String) -> String {
        switch self {
        case .speechStyle:
            "비격식체 어미가 사용되었습니다. '\(original)' 대신 합쇼체 표현인 '\(corrected)' 형태를 사용해야 합니다."
        case .humbleForm:
            "자신을 낮추는 겸양 표현이 필요합니다. '\(original)' 대신 '\(corrected)' 형태를 사용해야 합니다."
        case .subjectHonorific:
            "높여야 할 대상에는 높임 조사를 사용해야 합니다. '\(original)' 대신 '\(corrected)' 형태를 사용해야 합니다."
        }
    }
}
