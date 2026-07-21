//
//  QuestionSpeaking.swift
//  NOMA
//
//  Created by 이은지 on 7/18/26.
//

import Foundation

@MainActor
protocol QuestionSpeaking {
    func speak(_ text: String) async throws
    func stopSpeaking()
}
