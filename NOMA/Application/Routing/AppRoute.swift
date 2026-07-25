//
//  AppRoute.swift
//  NOMA
//
//  Created by 이은지 on 7/21/26.
//

import Foundation
import SwiftData

enum AppRoute: Hashable {
    case onboarding
    case permission
    case interviewPractice
    case answerAnalysisLoading(PersistentIdentifier)
    case practiceSummary(PersistentIdentifier)
    case learningHistory
}
