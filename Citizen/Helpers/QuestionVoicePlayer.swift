//
//  QuestionVoicePlayer.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class QuestionVoicePlayer {
    var isEnabled: Bool {
        voiceActing.isVoiceActingOn
    }
    
    private(set) var playingPart: QuestionVoicePart?
    
    private var playbackTask: Task<Void, Never>?
    
    private let voiceActing = VoiceActingManager.shared
    
    func play(part: QuestionVoicePart?, file: String?) {
        guard isEnabled else { return }
        playbackTask?.cancel()
        
        let duration = voiceActing.play(.questionAudio, fileName: file)
        
        guard duration > 0, part != nil else {
            playingPart = nil
            return
        }
        
        playingPart = part
        playbackTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard let self, !Task.isCancelled else { return }
            self.playingPart = nil
        }
    }
    
    func stop() {
        playbackTask?.cancel()
        playbackTask = nil
        playingPart = nil
        voiceActing.stop()
    }
}
