//
//  OverallFeedbackCardView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct OverallFeedbackCardView: View {
    
    // MARK: - Properties
    
    let feedbackText: String

    // MARK: - Body

    var body: some View {
        HStack(spacing: 10) {
            Text("💡")
                .font(.largeTitle)
            
            Text(feedbackText)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.accentColorBackground)
        )
    }
}
