//
//  SendableAudioBuffer.swift
//  NOMA
//
//  Created by 앤디 on 7/20/26.
//

import AVFoundation

struct RecordedAudioBuffer: @unchecked Sendable {
    let pcmBuffer: AVAudioPCMBuffer
}
