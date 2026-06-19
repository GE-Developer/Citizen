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
    let timer = Image(systemName: "timer")
    let send = Image(systemName: "arrow.up")
    let xmark = Image(systemName: "xmark")
    let number = Image(systemName: "number")
    let magnifyingglass = Image(systemName: "magnifyingglass")
    let darkMode = Image(systemName: "moon.fill")
    let language = Image(systemName: "globe")
    let vibration = Image(systemName: "iphone.radiowaves.left.and.right")
    let sound = Image(systemName: "speaker.wave.2.fill")
    let subscription = Image(systemName: "star")
    let star = Image(systemName: "star.fill")
    let restorePurchases = Image(systemName: "arrow.clockwise")
    let reviewLike = Image(systemName: "hand.thumbsup.fill")
    let termsOfUse = Image(systemName: "doc.plaintext")
    let privacyPolicy = Image(systemName: "lock.doc.fill")
    let developerTool = Image(systemName: "hammer.fill")
    let gear = Image(systemName: "gear")
    let warning = Image(systemName: "exclamationmark.triangle")
    let repeatArrow = Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
    let bookmark = Image(systemName: "bookmark.fill")
    let hint = Image(systemName: "lightbulb")
    let books = Image(systemName: "books.vertical.fill")
    let plus = Image(systemName: "plus")
    let paintpalette = Image(systemName: "paintpalette.fill")
    let code = Image(systemName: "chevron.left.slash.chevron.right")
    
    func key(_ isFilled: Bool = false) -> Image {
        Image(systemName: isFilled ? "key.fill" : "key")
    }
    
    func lock(_ isOpen: Bool) -> Image {
        isOpen ? Image(systemName: "lock.open.fill") : lock
    }
    
    func checkmarkInCircle(_ isFilled: Bool = true) -> Image {
        Image(systemName: isFilled ? "checkmark.circle.fill" : "circle")
    }
    
    func checkmarkAndXmark(_ isCorrect: Bool) -> Image {
        isCorrect ? Image(systemName: "checkmark") : xmark
    }
}

struct BackgroundImage {
}

struct ContentImage {
}

struct OtherImage {
    let iosDeveloperMichael = Image("iOS Developer")
    
    let svgLogo = Image("SVG Logo")
}
