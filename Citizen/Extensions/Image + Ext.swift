//
//  Image + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension Image {
    static let system = SystemImage()
    static let background = BackgroundImage()
    static let content = ContentImage()
    static let other = OtherImage()
}

struct SystemImage {
    let back = Image(systemName: "chevron.left")
    let chevron = Image(systemName: "chevron.right")
    let lock = Image(systemName: "lock.fill")
    let openLock = Image(systemName: "lock.open.fill")
    let timer = Image(systemName: "timer")
    let send = Image(systemName: "arrow.up")
    let xmark = Image(systemName: "xmark")
    let cryptoSettings = Image(systemName: "slider.horizontal.3")
    let number = Image(systemName: "number")
    let info = Image(systemName: "info.circle")
    let magnifyingglass = Image(systemName: "magnifyingglass")
    
    let darkMode = Image(systemName: "moon.fill")
    let language = Image(systemName: "globe")
    let vibration = Image(systemName: "iphone.radiowaves.left.and.right")
    let sound = Image(systemName: "speaker.wave.2.fill")
    let subscription = Image(systemName: "star")
    let star = Image(systemName: "star.fill")
    let restorePurchases = Image(systemName: "arrow.clockwise")
    let reviewLike = Image(systemName: "hand.thumbsup.fill")
    let rectangle = Image(systemName: "app.fill")
    let termsOfUse = Image(systemName: "doc.plaintext")
    let privacyPolicy = Image(systemName: "lock.doc.fill")
    let developerTool = Image(systemName: "hammer.fill")
    let gear = Image(systemName: "gear")
    let code = Image(systemName: "chevron.left.slash.chevron.right")
    let warning = Image(systemName: "exclamationmark.triangle")
    
    func key(_ isFilled: Bool = false) -> Image {
        isFilled ? Image(systemName: "key.fill") : Image(systemName: "key")
    }
    
    func lock(_ isOpen: Bool) -> Image {
        isOpen ? openLock : lock
    }
    
    func checkmarkInCircle(_ isFilled: Bool = true) -> Image {
        isFilled ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "circle")
    }
    
    func checkmarkAndXmark(_ isCorrect: Bool) -> Image {
        Image(systemName: isCorrect ? "checkmark" : "xmark")
    }
}

struct BackgroundImage {
    let aes256Argon2idVOID = Image("AES256+Argon2id+VOID")
    let emojiBackground = Image("EmojiBackground")
}

struct ContentImage {
    let voidAES256Argon2id = Image("VOID+AES256+Argon2id")
    let emoji = Image("Emoji")
}

struct OtherImage {
    let iosDeveloperMichael = Image("iOS Developer")
    let gitHub = Image("GitHub")
    
    let svgLogo = Image("SVG Logo")
}
