//
//  VoiceActingManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import AVFoundation
import Observation

@MainActor
@Observable
final class VoiceActingManager {
    var isVoiceActingOn: Bool {
        didSet { defaults.set(isVoiceActingOn, forKey: key) }
    }
    
    private(set) var unavailableNotice: String?
    
    private var player: AVAudioPlayer?
    private var restoreSessionTask: Task<Void, Never>?
    private var noticeTask: Task<Void, Never>?
    
    static let shared = VoiceActingManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.voiceActing.key
    private let mediaStore = MediaStore.shared
    
    private let notDownloadedNotice = L10n("VoiceActing.Unavailable.notDownloaded")
    private let missingNotice = L10n("VoiceActing.Unavailable.missing")
    
    private init() {
        isVoiceActingOn = defaults.object(forKey: key) as? Bool ?? true
    }
    
    func reset() {
        isVoiceActingOn = true
    }
    
    @discardableResult
    func play(_ kind: MediaKind, fileName: String?) -> TimeInterval {
        guard isVoiceActingOn else { return 0 }
        
        guard let fileName, !fileName.isEmpty else {
            showNotice(missingNotice)
            
            return 0
        }
        
        guard let url = localOrBundledURL(kind, fileName: fileName) else {
            showNotice(notDownloadedNotice)
            Task {
                _ = try? await mediaStore.fetch(kind, name: fileName)
            }
            
            return 0
        }
        
        activatePlaybackSession()
        player?.stop()
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
        
        let duration = player?.duration ?? 0
        
        scheduleSessionRestore(after: duration)
        
        return duration
    }
    
    func stop() {
        player?.stop()
        scheduleSessionRestore(after: 0)
    }
    
    private func localOrBundledURL(_ kind: MediaKind, fileName: String) -> URL? {
        if let url = MediaStore.shared.localURL(kind, name: fileName) {
            return url
        }
        
        let ns = fileName as NSString
        let ext = ns.pathExtension.isEmpty ? "mp3" : ns.pathExtension
        
        return Bundle.main.url(forResource: ns.deletingPathExtension, withExtension: ext)
    }
    
    private func showNotice(_ text: String) {
        noticeTask?.cancel()
        unavailableNotice = text
        noticeTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            unavailableNotice = nil
        }
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
