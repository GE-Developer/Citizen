//
//  DictionaryViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
@Observable
final class DictionaryViewModel {
    var selectedFilter: DictionaryFilter = .all
    var selectedSort: DictionarySortOrder = .recent
    var searchText = ""
    var selectedOccurrenceWord: WordEntry?
    var showAlphabet = false
    
    var availableFilters: [DictionaryFilter] {
        [.all] + dictionary.partsOfSpeech.map(DictionaryFilter.named)
    }
    
    var displayedWords: [WordEntry] {
        let filtered = words.filter { matchesFilter($0) && matchesSearch($0) }
        switch selectedSort {
        case .recent:
            return filtered
        case .alphabetical:
            return filtered.sorted {
                $0.lemma.word.localizedStandardCompare($1.lemma.word) == .orderedAscending
            }
        }
    }
    
    var isEmpty: Bool {
        words.isEmpty
    }
    
    var wordsCountText: String {
        "\(words.count)"
    }
    
    var voiceActingOn: Bool {
        VoiceActingManager.shared.isVoiceActingOn
    }
    
    var title: String {
        L10n("Dictionary.title")
    }
    
    var alphabetTitle: String {
        L10n("Alphabet.title")
    }
    
    var alphabetSubtitle: String {
        L10n("\(33) Dictionary.Alphabet.lettersCount")
    }
    
    var wordsSavedSuffix: String {
        L10n("\(words.count) Dictionary.wordsCountSuffix")
    }
    
    var searchPlaceholder: String {
        L10n("Dictionary.searchPlaceholder")
    }
    
    var savedAsLabel: String {
        L10n("Dictionary.savedAsLabel")
    }
    
    var removeActionTitle: String {
        L10n("Dictionary.removeActionTitle")
    }
    
    var noResultsText: String {
        L10n("Dictionary.noResultsText")
    }
    
    var emptyTitle: String {
        L10n("Dictionary.emptyTitle")
    }
    
    var emptyMessage: String {
        L10n("Dictionary.emptyMessage")
    }
    
    private(set) var isLoading = true
    
    private var words: [WordEntry] = []
    private var occurrenceCounts: [String: Int] = [:]
    
    let alphabetIconLetter = "ა"
    
    private let store = SavedWordsStore.shared
    private let dictionary = WordsDictionary.shared
    private let occurrences = WordOccurrenceIndex.shared
    private let hapticsManager = HapticsManager.shared
    
    func load() async {
        isLoading = true
        words = fetchSavedWords()
        await occurrences.prewarm()
        occurrenceCounts = countOccurrences(for: words)
        resetFilterIfUnavailable()
        isLoading = false
    }
    
    func remove(_ word: WordEntry) {
        hapticsManager.impact(style: .rigid)
        store.remove(word.key)
        words.removeAll { $0.key == word.key }
    }
    
    func openAlphabet() {
        hapticsManager.impact()
        showAlphabet = true
    }
    
    func showOccurrences(_ word: WordEntry) {
        hapticsManager.impact()
        selectedOccurrenceWord = word
    }
    
    func clearSearchText() {
        searchText = ""
    }
    
    func occurrenceCount(for word: WordEntry) -> Int {
        occurrenceCounts[word.key] ?? 0
    }
    
    func transliteration(_ value: String) -> String {
        "[\(value)]"
    }
    
    // Записи берутся из WordsDictionary по сохранённым ключам; всё на этом
    // экране по определению в словарике, поэтому isSaved сразу true.
    private func fetchSavedWords() -> [WordEntry] {
        store.fetchAll().compactMap { key in
            guard var entry = dictionary.entry(for: key) else { return nil }
            entry.isSaved = true
            return entry
        }
    }
    
    private func countOccurrences(for words: [WordEntry]) -> [String: Int] {
        Dictionary(
            words.map { ($0.key, occurrences.count(for: $0.key)) },
            uniquingKeysWith: { first, _ in first }
        )
    }
    
    private func resetFilterIfUnavailable() {
        if !availableFilters.contains(selectedFilter) {
            selectedFilter = .all
        }
    }
    
    private func matchesFilter(_ word: WordEntry) -> Bool {
        switch selectedFilter {
        case .all:            return true
        case .named(let pos): return word.partOfSpeech == pos
        }
    }
    
    private func matchesSearch(_ word: WordEntry) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return word.searchableText.localizedCaseInsensitiveContains(query)
    }
}
