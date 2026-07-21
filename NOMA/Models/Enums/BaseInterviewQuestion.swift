//
//  BaseInterviewQuestion.swift
//  NOMA
//
//  Created by 이은지 on 7/22/26.
//

import Foundation

enum BaseInterviewQuestion: Int, CaseIterable {
    case selfIntroduction
    case relevantExperience
    case strength

    var content: String {
        switch self {
        case .selfIntroduction: "자기소개를 해주십시오."
        case .relevantExperience: "지원한 직무와 관련된 본인의 경험을 설명해 주십시오."
        case .strength: "본인의 강점이 무엇입니까?"
        }
    }
}
