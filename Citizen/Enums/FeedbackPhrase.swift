//
//  FeedbackPhrase.swift
//  Citizen
//
//  Created by GE-Developer
//

@MainActor
enum FeedbackPhrase {
    static let correct: [String] = [
        L10n("FeedbackPhrase.Correct.1"),
        L10n("FeedbackPhrase.Correct.2"),
        L10n("FeedbackPhrase.Correct.3"),
        L10n("FeedbackPhrase.Correct.4"),
        L10n("FeedbackPhrase.Correct.5"),
        L10n("FeedbackPhrase.Correct.6"),
        L10n("FeedbackPhrase.Correct.7"),
        L10n("FeedbackPhrase.Correct.8"),
        L10n("FeedbackPhrase.Correct.9"),
        L10n("FeedbackPhrase.Correct.10")
    ]
    
    static let wrong: [String] = [
        L10n("FeedbackPhrase.Wrong.1"),
        L10n("FeedbackPhrase.Wrong.2"),
        L10n("FeedbackPhrase.Wrong.3"),
        L10n("FeedbackPhrase.Wrong.4"),
        L10n("FeedbackPhrase.Wrong.5"),
        L10n("FeedbackPhrase.Wrong.6"),
        L10n("FeedbackPhrase.Wrong.7"),
        L10n("FeedbackPhrase.Wrong.8"),
        L10n("FeedbackPhrase.Wrong.9"),
        L10n("FeedbackPhrase.Wrong.10")
    ]
    
    static func random(correct: Bool) -> String {
        (correct ? Self.correct : Self.wrong).randomElement() ?? ""
    }
}
