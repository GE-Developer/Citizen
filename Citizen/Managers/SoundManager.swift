//
//  SoundManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import AVFoundation

final class SoundManager {
    var isSoundOff: Bool {
        didSet { defaults.set(isSoundOff, forKey: key) }
    }
    
    static let shared = SoundManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.sound.key
    private var player: AVAudioPlayer?
    
    private init() {
        isSoundOff = defaults.bool(forKey: key)
        configureAudioSession()
    }
    
    func playSound(_ soundName: Sound) {
        guard !isSoundOff else { return }
        
        let url = Bundle.main.url(forResource: soundName.name, withExtension: "mp3")
        guard let url else { return }
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
    }
    
    private func configureAudioSession() {
        try? AVAudioSession
            .sharedInstance()
            .setCategory(.ambient, options: [.mixWithOthers])
        
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
