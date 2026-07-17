//
//  CapsuleButton.swift
//  NOMA
//
//  Created by 이은지 on 7/15/26.
//

import SwiftUI

struct CapsuleButton: View {
    
    // MARK: - Properties
    
    private let title: String
    private let capsuleButtonType: CapsuleButtonType
    private let action: () -> Void

    // MARK: - Initializer

    init(
        title: String,
        capsuleButtonType: CapsuleButtonType,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.capsuleButtonType = capsuleButtonType
        self.action = action
    }
    
    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
        }
        .buttonStyle(CapsuleButtonStyle(type: capsuleButtonType))
    }
}
