//
//  FoundationModelsGenerationError.swift
//  NOMA
//
//  Created by seokho on 7/21/26.
//

enum FoundationModelsGenerationError: Error {
    case contextWindowExceeded
    case guardrailViolation
    case generationFailed
}
