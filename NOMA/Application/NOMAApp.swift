//
//  NOMAApp.swift
//  NOMA
//
//  Created by 이은지 on 7/9/26.
//

import SwiftUI

@main
struct NOMAApp: App {
    var body: some Scene {
        WindowGroup {
            InterviewPracticeView()
        }

        Window("메모창", id: "memo") {
            MemoWindowView()
        }
        .defaultSize(width: 400, height: 405)
        .restorationBehavior(.disabled)
    }
}
