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
            OnboardingView()
        }
        .defaultSize(width: 1000, height: 700)
        .windowResizability(.contentSize)
    }
}
