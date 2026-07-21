//
//  FoundationModels+.swift
//  NOMA
//
//  Created by 이은지 on 7/19/26.
//

import FoundationModels

extension SystemLanguageModel.Availability {
    var isEnabled: Bool {
        switch self {
        case .available: return true
            
        case .unavailable: return false
        }
    }
}
