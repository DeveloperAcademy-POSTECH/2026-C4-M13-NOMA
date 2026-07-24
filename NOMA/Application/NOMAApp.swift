//
//  NOMAApp.swift
//  NOMA
//
//  Created by 이은지 on 7/9/26.
//

import SwiftData
import SwiftUI

@main
struct NOMAApp: App {
    @State private var memoStore = MemoStore()
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(memoStore)
        }
        .windowToolbarStyle(.unified(showsTitle: false))
        .modelContainer(for: PracticeRecord.self)

        Window(
            "메모창",
            id: "memo"
        ) {
            MemoWindowView()
                .environment(memoStore)
        }
        .defaultSize(
            width: 400,
            height: 405
        )
        .restorationBehavior(.disabled)
    }
}
