//
//  PushButton.swift
//  NOMA
//
//  Created by 이은지 on 7/17/26.
//

import SwiftUI

struct PushButton: View {

    // MARK: - Properties

    private let title: String
    private let type: PushButtonType
    private let size: PushButtonSize
    private let action: () -> Void

    // MARK: - Initializer

    init(
        title: String,
        type: PushButtonType,
        size: PushButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.size = size
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(PushButtonStyle(type: type, size: size))
    }
}
