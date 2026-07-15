//
//  JeongJoongButton.swift
//  NOMA
//
//  Created by 이은지 on 7/15/26.
//

import SwiftUI

struct JeongJoongButton: View {
    
    // MARK: - Properties
    
    private let title: String
    private let jeongJoongButtonType: JeongJoongButtonType
    private let radius: CGFloat
    private let action: (() -> Void)?

    // MARK: - Initializer

    init(
        title: String,
        jeongJoongButtonType: JeongJoongButtonType,
        radius: CGFloat,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.jeongJoongButtonType = jeongJoongButtonType
        self.radius = radius
        self.action = action
    }
    
    // MARK: - Body

    var body: some View {
        Button {
            action?()
        } label: {
            content
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews

extension JeongJoongButton {
    private var content: some View {
        Text(title)
            .font(.body)
            .foregroundStyle(jeongJoongButtonType.titleColor)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                jeongJoongButtonType.backgroundColor,
                in: RoundedRectangle(cornerRadius: radius)
            )
    }
}

#Preview {
    JeongJoongButton(
        title: "학습하기",
        jeongJoongButtonType: .primary,
        radius: 8
    )
}
