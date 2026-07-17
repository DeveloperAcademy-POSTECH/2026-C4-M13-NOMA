//
//  PushButtonSize.swift
//  NOMA
//
//  Created by 이은지 on 7/17/26.
//

import SwiftUI

enum PushButtonSize {
    case small
    case medium
    
    var height: CGFloat {
        switch self {
        case .small: return 24
        case .medium: return 44
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 13
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 16
        }
    }
    
    var font: Font {
        switch self {
        case .small: return .system(size: 13, weight: .medium)
        case .medium: return .system(size: 13, weight: .medium)
        }
    }
}
