//
//  SystemSettingsURL.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import Foundation

enum SystemSettingsURL {
    static let appleIntelligenceAndSiri = URL(string: "x-apple.systempreferences:com.apple.Siri-Settings.extension")
    static let microphone = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")
}
