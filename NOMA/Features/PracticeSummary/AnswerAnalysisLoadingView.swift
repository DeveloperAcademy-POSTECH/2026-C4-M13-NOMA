//
//  AnswerAnalysisLoadingView.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import SwiftUI

struct AnswerAnalysisLoadingView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            SpinningRingLoader()
                .frame(width: 32, height: 32)
            
            Text("답변을 분석하고 있습니다.")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("잠시만 기다려 주십시오.")
                .font(.title2)
                .foregroundStyle(.primary)
        }
    }
}
