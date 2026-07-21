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
    @Guide(description: "Every expression that was changed, in the order they appear in the input sentence. Empty array if nothing changed", .maximumCount(3))
    let corrections: [Correction]
    @Guide(description: "true if revisedSentence is different from the input sentence, false if it is unchanged")
    let feedback: Bool
}
