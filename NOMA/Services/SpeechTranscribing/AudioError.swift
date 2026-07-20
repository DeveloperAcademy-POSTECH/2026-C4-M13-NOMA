//
//  AudioError.swift
//  NOMA
//
//  Created by 앤디 on 7/20/26.
//

import Foundation

enum AudioError: Error {
    case formatNotFound
}

extension AudioError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .formatNotFound:
            return "오디오 포맷을 찾을 수 없습니다."
        }
    }
}
