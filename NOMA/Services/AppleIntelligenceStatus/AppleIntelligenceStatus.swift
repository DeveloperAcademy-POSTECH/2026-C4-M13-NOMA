//
//  AppleIntelligenceStatus.swift
//  NOMA
//
//  Created by 이은지 on 7/19/26.
//

import FoundationModels
import Observation

@Observable
final class AppleIntelligenceStatus {
    
    // MARK: - Properties
    
    private(set) var isEnabled: Bool = false
    private(set) var feedbackMessage: String?

    // MARK: - Functions
    
    func refresh() {
        let availability = SystemLanguageModel.default.availability
        isEnabled = availability.isEnabled
        feedbackMessage = Self.feedbackMessage(for: availability.unavailableReason)
    }

    private static func feedbackMessage(
        for reason: SystemLanguageModel.Availability.UnavailableReason?
    ) -> String? {
        guard let reason else { return nil }

        switch reason {
        case .modelNotReady:
            return "Apple Intelligence 모델을 준비하는 중입니다. 잠시 후 다시 확인해 주십시오."
            
        case .deviceNotEligible:
            return "이 기기는 Apple Intelligence를 지원하지 않습니다."
            
        case .appleIntelligenceNotEnabled:
            return nil
            
        @unknown default:
            return "알 수 없는 이유로 Apple Intelligence를 사용할 수 없습니다."
        }
    }
}
