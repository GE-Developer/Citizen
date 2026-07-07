//
//  VoiceActingManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import AVFoundation

@MainActor
final class VoiceActingManager {
    var isVoiceActingOn: Bool {
        didSet { defaults.set(isVoiceActingOn, forKey: key) }
    }
    
    static let shared = VoiceActingManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.voiceActing.key
    
    private var player: AVAudioPlayer?
    private var restoreSessionTask: Task<Void, Never>?
    
    private init() {
        isVoiceActingOn = defaults.object(forKey: key) as? Bool ?? true
    }
    
    func reset() {
        isVoiceActingOn = true
    }
    
    @discardableResult
    func playFile(_ fileName: String) -> TimeInterval {
        guard isVoiceActingOn else { return 0 }
        
        let ns = fileName as NSString
        let name = ns.deletingPathExtension
        let ext = ns.pathExtension.isEmpty ? "mp3" : ns.pathExtension
        guard !name.isEmpty,
              let url = Bundle.main.url(forResource: name, withExtension: ext)
        else { return 0 }
        
        activatePlaybackSession()
        player?.stop()
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
        
        let duration = player?.duration ?? 0
        scheduleSessionRestore(after: duration)
        return duration
    }
    
    private func activatePlaybackSession() {
        restoreSessionTask?.cancel()
        try? AVAudioSession
            .sharedInstance()
            .setCategory(.playback, options: [.mixWithOthers])
    }
    
    private func scheduleSessionRestore(after duration: TimeInterval) {
        restoreSessionTask = Task {
            try? await Task.sleep(for: .seconds(duration + 0.2))
            guard !Task.isCancelled, player?.isPlaying != true else { return }
            try? AVAudioSession.sharedInstance().setCategory(.ambient)
        }
    }
}
