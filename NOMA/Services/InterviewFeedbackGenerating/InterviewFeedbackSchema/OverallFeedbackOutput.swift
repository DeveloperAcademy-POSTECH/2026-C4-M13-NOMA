//
//  OverallFeedbackOutput.swift
//  NOMA
//
//  Created by seokho on 7/21/26.
//

import FoundationModels

@Generable
struct OverallFeedbackOutput {
    @Guide(description: "One Korean sentence stating what the interviewee repeatedly got wrong")
    let mostFrequentMistake: String
    @Guide(description: "One Korean sentence advising how to fix it in the next answer")
    let advice: String
}
