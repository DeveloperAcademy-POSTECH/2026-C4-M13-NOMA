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
    private let titleColor: Color
    private let backgroundColor: Color
    private let radius: CGFloat
    private let action: (() -> Void)?

    // MARK: - Initializer

    init(
        titleText: String,
        titleColor: Color,
        backgroundColor: Color,
        radius: CGFloat,
        action: (() -> Void)? = nil
    ) {
        self.title = titleText
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
        self.radius = radius
        self.action = action
    }
    
    // MARK: - Body

    var body: some View {
        Button {
            action?()
        } label: {
            Text(title)
                .font(.body)
                .foregroundStyle(titleColor)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .background(
                    backgroundColor,
                    in: RoundedRectangle(cornerRadius: radius)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    JeongJoongButton(
        titleText: "학습하기",
        titleColor: .white,
        backgroundColor: .accentColor,
        radius: 3
    )
}
