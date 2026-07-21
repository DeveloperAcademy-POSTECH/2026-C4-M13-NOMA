//
//  SpinningRingLoader.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct SpinningRingLoader: View {

    // MARK: - Properties

    @State private var isRotating = false

    private let lineWidth: CGFloat = 6
    private let trimFraction: CGFloat = 0.25
    private let borderLineWidth: CGFloat = 1

    // MARK: - Body

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: lineWidth
                )

            Circle()
                .stroke(
                    Color.gray.opacity(0.25),
                    lineWidth: borderLineWidth
                )
                .padding(-lineWidth / 2)

            Circle()
                .stroke(
                    Color.gray.opacity(0.25),
                    lineWidth: borderLineWidth
                )
                .padding(lineWidth / 2)

            Circle()
                .trim(from: 0, to: trimFraction)
                .stroke(
                    Color.blue,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(
                    .linear(duration: 1).repeatForever(autoreverses: false),
                    value: isRotating
                )
        }
        .onAppear {
            isRotating = true
        }
    }
}
