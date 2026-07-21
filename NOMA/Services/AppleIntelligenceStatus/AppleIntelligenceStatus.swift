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
    private(set) var isEnabled: Bool = false

    func refresh() {
        isEnabled = SystemLanguageModel.default.availability.isEnabled
    }
}
