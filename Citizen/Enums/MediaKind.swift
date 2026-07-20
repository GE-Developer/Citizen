//
//  MediaKind.swift
//  Citizen
//
//  Created by GE-Developer
//

enum MediaKind {
    case alphabetImage
    case alphabetLetterAudio
    case alphabetExampleAudio
    case questionAudio
    
    var folder: String {
        switch self {
        case .alphabetImage:
            return "Alphabet/Example Images"
        case .alphabetLetterAudio:
            return "Alphabet/Letter Audio"
        case .alphabetExampleAudio:
            return "Alphabet/Example Audio"
        case .questionAudio:
            return "Questions"
#warning("questionAudio подка добавлено условно, нужно сделать правильный путь")
        }
    }
    
    var versionRow: String {
        switch self {
        case .alphabetImage, .alphabetLetterAudio, .alphabetExampleAudio:
            return "media"
        case .questionAudio:
            return "question-audio"
#warning("Аналогично - путь неверный")
#warning("Скорее всего надо сделать в одной папке с media")
        }
    }
}
