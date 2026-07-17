//
//  PushButtonType.swift
//  NOMA
//
//  Created by 이은지 on 7/17/26.
//

import SwiftUI

enum PushButtonType {
    case neutral
    case `default`
    case borderless
    
    func titleColor(for status: PushButtonStatus) -> Color {
        switch (self, status) {
        case (.neutral, .normal), (.neutral, .hover): return Color(nsColor: .labelColor)
        case (.neutral, .disabled): return Color(nsColor: .tertiaryLabelColor)
        case (.default, .normal), (.default, .hover): return .blue
        case (.default, .disabled): return .blue.opacity(0.35)
        case (.borderless, .normal), (.borderless, .hover): return .accentColor
        case (.borderless, .disabled): return .accentColor.opacity(0.35)
        }
    }
    
    func backgroundColor(for status: PushButtonStatus) -> Color {
        switch (self, status) {
        case (.neutral, .normal): return .black.opacity(0.05)
        case (.neutral, .hover): return .black.opacity(0.15)
        case (.neutral, .disabled): return .black.opacity(0.05)
        case (.default, .normal), (.default, .hover), (.default, .disabled): return .blue.opacity(0.1)
        case (.borderless, .normal): return .clear
        case (.borderless, .hover), (.borderless, .disabled): return Color(nsColor: .tertiaryLabelColor).opacity(0.12)
        }
    }
    
    func overlayColor(for status: PushButtonStatus) -> Color? {
        switch (self, status) {
        case (.default, .hover): return .black.opacity(0.08)
        default: return nil
        }
    }
}
