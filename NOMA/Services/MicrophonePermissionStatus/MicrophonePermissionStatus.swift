//
//  MicrophonePermissionStatus.swift
//  NOMA
//
//  Created by 이은지 on 7/20/26.
//

import AppKit
import AVFoundation
import Observation

@Observable
final class MicrophonePermissionStatus {
    private(set) var isGranted: Bool = false

    func refresh() {
        isGranted = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

    func requestAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            isGranted = true
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                Task { @MainActor in
                    self?.isGranted = granted
                }
            }
            
        case .denied, .restricted:
            openMicrophoneSettings()
            
        default:
            openMicrophoneSettings()
        }
    }

    private func openMicrophoneSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
