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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PracticeAnswer.self])
        .modelContainer(for: [InterviewQuestion.self])
    }
}
