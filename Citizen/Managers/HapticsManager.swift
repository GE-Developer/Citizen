//
//  HapticsManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import UIKit

final class HapticsManager {
    var isHapticsOff: Bool {
        didSet { defaults.set(isHapticsOff, forKey: key) }
    }
    
    static let shared = HapticsManager()
    
    private let defaults = UserDefaults.standard
    private let key = AppStorageKey.haptics.key
    
    private init() {
        isHapticsOff = defaults.bool(forKey: key)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, vol: CGFloat = 1, delay: Double = 0) {
        guard !isHapticsOff else { return }
        
        let impactGenerator = UIImpactFeedbackGenerator(style: style)
        impactGenerator.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            impactGenerator.impactOccurred(intensity: vol)
        }
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType, delay: Double = 0) {
        guard !isHapticsOff else { return }
        
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            notificationGenerator.notificationOccurred(type)
        }
    }
    
    func selectionChanged(delay: Double = 0) {
        guard !isHapticsOff else { return }
        
        let selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            selectionGenerator.selectionChanged()
        }
    }
}
