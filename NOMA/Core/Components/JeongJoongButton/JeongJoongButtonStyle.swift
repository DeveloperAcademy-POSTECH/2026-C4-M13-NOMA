//
//  JeongJoongButtonStyle.swift
//  NOMA
//
//  Created by 이은지 on 7/17/26.
//

import SwiftUI

struct JeongJoongButtonStyle: ButtonStyle {
    
    // MARK: - Properties

    let type: JeongJoongButtonType

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false
    
    // MARK: - Functions
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(type.titleColor)
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

    private var currentBackgroundColor: Color {
        guard isEnabled else { return type.disabledBackgroundColor }
        
        return isHovering
        ? type.hoverBackgroundColor
        : type.backgroundColor
    }
}
