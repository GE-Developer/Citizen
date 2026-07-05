//
//  HintViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

// Строка варианта ответа на экране подсказки: грузинское слово + грамматическая
// подсказка из словаря ("he / she — nominative") + признак правильного.
struct HintAnswerRow: Identifiable, Hashable {
    let label: String
    let text: String
    let segments: [RichTextSegment]
    let translation: String?
    let isCorrect: Bool

    var id: String { label }
}

@MainActor
@Observable
final class HintViewModel {

    // MARK: - var
    var selectedWord: WordEntry?

    // MARK: - let
    let subTitle: String
    let questionText: String
    let questionSegments: [RichTextSegment]
    let questionTranslation: String?
    let sentenceSegments: [RichTextSegment]
    let sentenceTranslationSegments: [RichTextSegment]?
    let hasSentence: Bool
    let answerRows: [HintAnswerRow]

    // Заголовки/тексты экрана (новый дизайн, английский — без L10n, как в QuestionsViewModel).
    let title = "Hint"
    let questionHeader = "QUESTION"
    let sentenceHeader = "SENTENCE"
    let answersHeader = "ANSWER CHOICES"
    let inSentenceHeader = "IN THIS SENTENCE"
    let dictionaryFormHeader = "DICTIONARY FORM"
    let saveButtonTitle = "Save to dictionary"
    let savedButtonTitle = "In your dictionary"

    // MARK: - private let
    private let dictionary = WordsDictionary.shared
    private let store = SavedWordsStore.shared
    private let haptic = HapticsManager.shared

    // MARK: - init
    init(question: Question) {
        self.subTitle = question.number
        self.questionText = question.question
        self.questionSegments = question.question.asRichSegments

        let additional = question.additionalText ?? ""
        self.hasSentence = !additional.isEmpty
        self.sentenceSegments = additional.asRichSegments

        // Перевод вопроса/предложения/ответов на язык пользователя (nil для ka).
        let translated = QuestionTranslations.shared.question(forID: question.id)
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

    // MARK: - func

    // Тап по подчёркнутому слову → открыть карточку, если слово есть в словаре.
    func selectWord(_ token: String) {
        guard var entry = dictionary.entry(for: token) else { return }
        entry.isSaved = store.contains(entry.key)
        selectedWord = entry
    }

    func dismissWord() {
        selectedWord = nil
    }

    // Кнопка Save / In your dictionary в карточке.
    func toggleSave() {
        guard var detail = selectedWord else { return }
        detail.isSaved = store.toggle(detail.key)
        selectedWord = detail
        haptic.selectionChanged()
    }
}
