//
//  MemoWindowView.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import SwiftUI

struct MemoWindowView: View {

    @State private var text = ""

    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: 13))
            .padding(12)
            .frame(minWidth: 300, minHeight: 200)
            .accessibilityLabel("면접 메모")
            .accessibilityHint("면접 중 기억할 내용을 입력합니다")
    }
}
