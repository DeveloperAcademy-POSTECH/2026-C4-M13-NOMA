//
//  FoundationModelsFeedbackService.swift
//  NOMA
//
//  Created by seokho on 7/19/26.
//

import Foundation
import FoundationModels

actor FoundationModelsFeedbackService: InterviewFeedbackGenerating {
    private var currentTask: Task<SentenceFeedback?, any Error>?
    
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
            
            let cleanedOriginal = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanedRevised = feedbackOutput.revisedSentence.trimmingCharacters(in: .whitespacesAndNewlines)

            if feedbackOutput.feedback && cleanedRevised != cleanedOriginal {
                return SentenceFeedback(revisedSentence: feedbackOutput.revisedSentence, explanation: feedbackOutput.explanation)
            } else {
                return nil
            }
        } catch {
            throw foundationModelsError(error)
        }
    }
    
    func generateOverallFeedback(items: [FeedbackItem]) async throws(FoundationModelsGenerationError) -> String {
        _ = await currentTask?.result
        
        do {
            let session = LanguageModelSession {
                OverallFeedbackInstructions.instructions
            }
            return try await session.respond(to: items.map { $0.explanation }.joined(separator: "\n")).content
        } catch {
            throw foundationModelsError(error)
        }
    }
    
    nonisolated func stopFeedback() {
        Task { await self.cancel() }
    }
}
