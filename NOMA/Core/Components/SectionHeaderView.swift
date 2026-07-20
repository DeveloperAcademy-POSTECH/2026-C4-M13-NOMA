//
//  SectionHeaderView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct SectionHeaderView: View {

    // MARK: - Properties

    let title: String
    let actionTitle: String
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            content

            Divider()
        }
    }
}

// MARK: - Subviews

extension SectionHeaderView {
    private var content: some View {
        HStack {
            sectionHeaderTitle

            Spacer()
            
            sectionHeaderButton
        }
        .padding(.horizontal, 30)
        .frame(height: 78)
    }
    
    private var sectionHeaderTitle: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
    }
    
    private var sectionHeaderButton: some View {
        PushButton(
            title: actionTitle,
            type: .borderless,
            size: .small,
            action: action
        )
    }
}
