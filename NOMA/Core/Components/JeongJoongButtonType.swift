//
//  JeongJoongButtonType.swift
//  NOMA
//
//  Created by 이은지 on 7/15/26.
//

import Foundation
import SwiftUI

enum JeongJoongButtonType: CaseIterable, Codable {
    case primary
    case secondary
    
    var titleColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return Color(nsColor: .labelColor)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .primary: return .accentColor
        case .secondary: return Color(nsColor: .secondarySystemFill)
        }
    }
}
