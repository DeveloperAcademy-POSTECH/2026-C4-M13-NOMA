//
//  FoundationModelsFeedbackService.swift
//  NOMA
//
//  Created by seokho on 7/19/26.
//

import Foundation
import FoundationModels

actor FoundationModelsFeedbackService: InterviewFeedbackGenerating {
    
    // MARK: - Properties
    
    private var currentTask: Task<SentenceFeedback?, any Error>?
    
    // MARK: - Functions
    
    private func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    func generateFeedback(sentence: String) async throws(FoundationModelsGenerationError) -> SentenceFeedback? {
        let previous = currentTask
        let task = Task {
            _ = await previous?.result
            return try await performGeneration(sentence: sentence)
        }
        currentTask = task
        do {
            return try await task.value
        } catch let error as FoundationModelsGenerationError {
            throw error
        } catch {
            throw .generationFailed
        }
    }
    
    private func performGeneration(sentence: String) async throws(FoundationModelsGenerationError) -> SentenceFeedback? {
        do {
            let session = LanguageModelSession {
                FeedbackInstructions.instructions
            }
            
            let feedbackOutput = try await session.respond(
                to: sentence,
                generating: FoundationModelsOutput.self,
            ).content
            
            let valid = feedbackOutput.corrections.filter {
                !$0.originalExpression.isEmpty
                    && sentence.contains($0.originalExpression)
                    && feedbackOutput.revisedSentence.contains($0.correctedExpression)
                    && $0.originalExpression != $0.correctedExpression
            }

            guard feedbackOutput.feedback, !valid.isEmpty else { return nil }

            return SentenceFeedback(
                revisedSentence: feedbackOutput.revisedSentence,
                explanation: valid
                    .map { $0.reason.explanation(from: $0.originalExpression, to: $0.correctedExpression) }
                    .joined(separator: " "),
                corrections: valid
            )
        } catch {
            throw foundationModelsError(error)
        }
    }
    
    func generateOverallFeedback(items: [FeedbackItem]) async throws(FoundationModelsGenerationError) -> String {
        _ = await currentTask?.result
        
        let reasons = items.flatMap { $0.corrections.map(\.reason) }
        let order: [FeedbackReason] = [.speechStyle, .humbleForm, .subjectHonorific]
        let counts = order.map { reason in (reason, reasons.count { $0 == reason }) }
        guard let top = counts.max(by: { $0.1 < $1.1 }), top.1 > 0 else { return "" }
        
        do {
            let session = LanguageModelSession {
                OverallFeedbackInstructions.instructions
            }
            let output = try await session.respond(
                to: "\(top.0) \(top.1)회",
                generating: OverallFeedbackOutput.self
            ).content
            return "\(output.mostFrequentMistake) \(output.advice)"
        } catch {
            throw foundationModelsError(error)
        }
    }
    
    nonisolated func stopFeedback() {
        Task { await self.cancel() }
    }
}
