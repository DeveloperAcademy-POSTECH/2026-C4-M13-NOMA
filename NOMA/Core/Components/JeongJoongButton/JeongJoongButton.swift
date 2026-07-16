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
    private let action: (() -> Void)

    // MARK: - Initializer

    init(
        title: String,
        jeongJoongButtonType: JeongJoongButtonType,
        action: @escaping (() -> Void)
    ) {
        self.title = title
        self.jeongJoongButtonType = jeongJoongButtonType
        self.action = action
    }
    
    // MARK: - Body

    var body: some View {
        Button {
            action()
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
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(jeongJoongButtonType.titleColor)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                jeongJoongButtonType.backgroundColor,
                in: Capsule()
            )
    }
}
