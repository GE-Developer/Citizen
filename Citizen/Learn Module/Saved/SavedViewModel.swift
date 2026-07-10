//
//  SavedViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class SavedViewModel: ObservableObject {
    @Published var chosenFolder: QuestionFolder?
    @Published var showRenameAlert = false
    @Published var renameFolderName = ""

    @Published private(set) var folders: [QuestionFolder] = []

    var isEmpty: Bool {
        folders.isEmpty
    }

    var canRename: Bool {
        !renameFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasAnyQuestions: Bool {
        folders.contains { $0.count > 0 }
    }

    var foldersCountText: String {
        "\(folders.count)"
    }
    
    var foldersCountSuffix: String {
        L10n("\(folders.count) Saved.folderCountSuffix")
    }

    private var folderToRename: QuestionFolder?

    let title = L10n("Main.Saved.title")
    let emptyFoldersText = L10n("Questions.SaveSheet.emptyFolders")
    let emptyMessage = L10n("Saved.emptyMessage")
    let removeActionTitle = L10n("Saved.removeFolder")
    let renameActionTitle = L10n("Saved.renameFolder")
    let renameConfirmTitle = L10n("Saved.renameConfirm")
    let renameCancelTitle = L10n("SearchField.cancel")
    let renamePlaceholder = L10n("Questions.SaveSheet.newFolder")
    let practiceTitle = L10n("Saved.Practice.title")
    let practiceSubtitle = L10n("Saved.Practice.allSubtitle")

    private let savedStore = SavedQuestionsStore.shared
    private let haptics = HapticsManager.shared
    
    init() {
        refresh()
    }

    func refresh() {
        folders = savedStore.folders()
    }
    
    func folderPressed(_ folder: QuestionFolder) {
        haptics.impact()
        chosenFolder = folder
    }

    func practicePressed() {
        haptics.impact()
    }

    func hasQuestions(_ folder: QuestionFolder) -> Bool {
        folder.count > 0
    }
    
    func remove(_ folder: QuestionFolder) {
        haptics.impact(style: .rigid)
        savedStore.removeFolder(folder.id)
        folders.removeAll { $0.id == folder.id }
    }

    func renamePressed(_ folder: QuestionFolder) {
        haptics.impact()
        folderToRename = folder
        renameFolderName = folder.name
        showRenameAlert = true
    }

    func confirmRename() {
        let name = renameFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let folder = folderToRename, !name.isEmpty, name != folder.name else { return }
        savedStore.renameFolder(folder.id, to: name)
        haptics.notification(type: .success)
        refresh()
    }
    
    func questionCountText(_ folder: QuestionFolder) -> String {
        L10n("Questions.SaveSheet.folderCount \(folder.count)")
    }
}
