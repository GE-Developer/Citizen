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
    
    private init() {
        isVoiceActingOn = defaults.object(forKey: key) as? Bool ?? true
        configureAudioSession()
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
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
        return player?.duration ?? 0
    }
    
    private func configureAudioSession() {
        try? AVAudioSession
            .sharedInstance()
            .setCategory(.ambient, options: [.mixWithOthers])
        
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
