//
//  foundationModelsError.swift
//  NOMA
//
//  Created by seokho on 7/21/26.
//

import FoundationModels

nonisolated func foundationModelsError(_ error: any Error) -> FoundationModelsGenerationError {
    
    guard let error = error as? LanguageModelSession.GenerationError else { return .generationFailed }
    
    switch error {
    case .exceededContextWindowSize: return .contextWindowExceeded
    case .guardrailViolation: return .guardrailViolation
    default: return .generationFailed
    }
}
