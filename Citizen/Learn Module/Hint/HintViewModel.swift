//
//  HintViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class HintViewModel {
    var selectedWord: WordEntry?
    var showCorrectAnswer = false
    
    let subTitle: String
    let questionSegments: [RichTextSegment]
    let questionTranslation: String?
    let sentenceSegments: [RichTextSegment]
    let sentenceTranslationSegments: [RichTextSegment]?
    let hasSentence: Bool
    let answerRows: [HintAnswerRow]
    
    let title = L10n("Hint.title")
    let questionHeader = L10n("Hint.questionHeader")
    let sentenceHeader = L10n("Hint.sentenceHeader")
    let answersHeader = L10n("Hint.answersHeader")
    let inSentenceHeader = L10n("Hint.WordDetail.inSentenceHeader")
    let dictionaryFormHeader = L10n("Hint.WordDetail.dictionaryFormHeader")
    let saveButtonTitle = L10n("Hint.WordDetail.saveButton")
    let savedButtonTitle = L10n("Hint.WordDetail.savedButton")
    let showAnswerTitle = L10n("Hint.showAnswer")
    
    private let dictionary = WordsDictionary.shared
    private let store = SavedWordsStore.shared
    private let haptic = HapticsManager.shared
    
    init(question: Question) {
        self.subTitle = question.number
        self.questionSegments = question.question.asRichSegments
        
        let additional = question.additionalText ?? ""
        
        self.hasSentence = !additional.isEmpty
        self.sentenceSegments = additional.asRichSegments
        
        let translated = QuizRepository.shared.translation(forID: question.id)
        
        self.questionTranslation = translated?.question
        self.sentenceTranslationSegments = translated?.additionalText?.asRichSegments
        
        let answerTranslations = Dictionary(
            (translated?.answers ?? []).map { ($0.label, $0.text) },
            uniquingKeysWith: { first, _ in first }
        )
        
        self.answerRows = question.answers.map { answer in
            HintAnswerRow(
                label: answer.label,
                text: answer.text,
                segments: answer.text.asRichSegments,
                translation: answerTranslations[answer.label],
                isCorrect: answer.isCorrect
            )
        }
    }
    
    func selectWord(_ token: String) {
        guard var entry = dictionary.entry(for: token) else { return }
        entry.isSaved = store.contains(entry.key)
        selectedWord = entry
    }
    
    func transliterationText(_ value: String) -> String {
        "[\(value)]"
    }
    
    func toggleSave() {
        guard var detail = selectedWord else { return }
        detail.isSaved = store.toggle(detail.key)
        selectedWord = detail
        haptic.selectionChanged()
    }
}
