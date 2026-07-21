//
//  FoundationModelsOutput.swift
//  NOMA
//
//  Created by seokho on 7/21/26.
//

import FoundationModels

@Generable
struct FoundationModelsOutput {
    @Guide(description: "The input sentence corrected to formal interview style (합쇼체, 겸양 표현·주체높임·상대높임). If the sentence is already correct, output the original sentence unchanged")
    let revisedSentence: String
    @Guide(description: "If revisedSentence is different from the input, 1-2 sentences in Korean explaining what was changed and why. If nothing was changed, an empty string")
    let explanation: String
    @Guide(description: "true if revisedSentence is different from the input sentence, false if it is unchanged")
    let feedback: Bool
}
