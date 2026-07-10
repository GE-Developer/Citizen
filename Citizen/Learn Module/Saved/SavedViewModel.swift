//
//  SavedViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class SavedViewModel: ObservableObject {
    @Published private(set) var folders: [QuestionFolder] = []

    var foldersCountText: String {
        "\(folders.count)"
    }

    var foldersCountSuffix: String {
        L10n("\(folders.count) Saved.folderCountSuffix")
    }

    let title = L10n("Main.Saved.title")
    let emptyFoldersText = L10n("Questions.SaveSheet.emptyFolders")
    let removeActionTitle = L10n("Saved.removeFolder")

    private let savedStore = SavedQuestionsStore.shared
    private let haptics = HapticsManager.shared

    init() {
        folders = savedStore.folders()
    }

    func folderPressed(_ folder: QuestionFolder) {
        haptics.impact()
    }

    func remove(_ folder: QuestionFolder) {
        haptics.impact(style: .rigid)
        savedStore.removeFolder(folder.id)
        folders.removeAll { $0.id == folder.id }
    }

    func questionCountText(_ folder: QuestionFolder) -> String {
        L10n("Questions.SaveSheet.folderCount \(folder.count)")
    }
}
