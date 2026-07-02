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
    var selectedOccurrenceWord: SavedWord?
    var showAlphabet = false
    
    var availableFilters: [DictionaryFilter] {
        [.all] + dictionary.partsOfSpeech.map(DictionaryFilter.partOfSpeech)
    }
    
    var displayedWords: [SavedWord] {
        let filtered = words.filter { matchesFilter($0) && matchesSearch($0) }
        switch selectedSort {
        case .recent:
            return filtered
        case .alphabetical:
            return filtered.sorted {
                $0.lemmaWord.localizedStandardCompare($1.lemmaWord) == .orderedAscending
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
    
    private var words: [SavedWord] = []
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
    
    func remove(_ word: SavedWord) {
        hapticsManager.impact(style: .rigid)
        store.remove(word.key)
        words.removeAll { $0.key == word.key }
    }
    
    func openAlphabet() {
        hapticsManager.impact()
        showAlphabet = true
    }
    
    func showOccurrences(_ word: SavedWord) {
        hapticsManager.impact()
        selectedOccurrenceWord = word
    }
    
    func clearSearchText() {
        searchText = ""
    }
    
    func occurrenceCount(for word: SavedWord) -> Int {
        occurrenceCounts[word.key] ?? 0
    }
    
    func transliteration(_ value: String) -> String {
        "[\(value)]"
    }
    
    private func fetchSavedWords() -> [SavedWord] {
        store.fetchAll().compactMap { key in
            dictionary
                .entry(for: key)
                .map { SavedWord(key: key, entry: $0) }
        }
    }
    
    private func countOccurrences(for words: [SavedWord]) -> [String: Int] {
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
    
    private func matchesFilter(_ word: SavedWord) -> Bool {
        switch selectedFilter {
        case .all:                   return true
        case .partOfSpeech(let pos): return word.partOfSpeech == pos
        }
    }
    
    private func matchesSearch(_ word: SavedWord) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return word.searchableText.localizedCaseInsensitiveContains(query)
    }
}
