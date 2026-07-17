//
//  JeongJoongButtonType.swift
//  NOMA
//
//  Created by 이은지 on 7/15/26.
//

import SwiftUI

enum JeongJoongButtonType {
    case primary
    case secondary
    
    var titleColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return Color(nsColor: .labelColor)
        }
    }
    
    var disabledTitleColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return Color(nsColor: .tertiaryLabelColor)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .primary: return .accentColor
        case .secondary: return Color(nsColor: .secondarySystemFill)
        }
    }

    var hoverBackgroundColor: Color {
        switch self {
        case .primary: return Color(hexCode: 0x14356D)
        case .secondary: return .labelPrimary
        }
    }

    var disabledBackgroundColor: Color {
        switch self {
        case .primary: return .accentColor.opacity(0.35)
        case .secondary: return Color(nsColor: .tertiarySystemFill)
        }
    }
}
