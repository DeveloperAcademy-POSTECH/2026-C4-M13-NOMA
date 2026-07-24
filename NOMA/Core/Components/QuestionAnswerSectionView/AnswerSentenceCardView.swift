//
//  AnswerSentenceCardView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct AnswerSentenceCardView: View {

    // MARK: - Properties

    let text: String

    // MARK: - Body

    var body: some View {
        HStack {
            Text(text)
                .font(.title3)
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.thickMaterial.opacity(0.28))
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("답변 문장, \(text)")
    }
}
