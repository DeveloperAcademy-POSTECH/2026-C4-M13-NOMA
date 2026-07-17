//
//  PushButtonStyle.swift
//  NOMA
//
//  Created by 이은지 on 7/17/26.
//

import SwiftUI

struct PushButtonStyle: ButtonStyle {
    
    // MARK: - Properties

    let type: PushButtonType
    let size: PushButtonSize
    
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false
    
    private var currentStatus: PushButtonStatus {
        guard isEnabled else { return .disabled }
        
        return isHovering
            ? .hover
            : .normal
    }
    
    // MARK: - Functions

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(type.titleColor(for: currentStatus))
            .frame(height: size.height)
            .padding(
                .horizontal,
                size.horizontalPadding
            )
            .background(
                type.backgroundColor(for: currentStatus),
                in: RoundedRectangle(cornerRadius: 6)
            )
            .overlay {
                if let overlayColor = type.overlayColor(for: currentStatus) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(overlayColor)
                }
            }
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
}
