//
//  CapsuleButtonStyle.swift
//  NOMA
//
//  Created by 이은지 on 7/17/26.
//

import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    
    // MARK: - Properties

    let type: CapsuleButtonType

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false
    
    // MARK: - Functions
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(currentTitleColor)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                currentBackgroundColor,
                in: Capsule()
            )
            .onHover { hovering in
                isHovering = hovering
                guard isEnabled else { return }
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
    }

    private var currentTitleColor: Color {
        isEnabled
        ? type.titleColor
        : type.disabledTitleColor
    }
    
    private var currentBackgroundColor: Color {
        guard isEnabled else { return type.disabledBackgroundColor }
        
        return isHovering
        ? type.hoverBackgroundColor
        : type.backgroundColor
    }
}
