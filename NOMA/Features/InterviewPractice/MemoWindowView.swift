//
//  MemoWindowView.swift
//  NOMA
//
//  Created by myone on 7/21/26.
//

import SwiftUI

struct MemoWindowView: View {
    @Environment(MemoStore.self) private var memoStore

    var body: some View {
        @Bindable var memoStore = memoStore
        TextEditor(text: $memoStore.text)
            .font(.system(size: 13))
            .padding(12)
            .frame(minWidth: 300, minHeight: 200)
    }
}
