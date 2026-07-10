//
//  SavedView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SavedView: View {
    @StateObject private var vm = SavedViewModel()

    @State private var fadingIDs: Set<String> = []

    var body: some View {
        savedFolders
    }
}

// MARK: - Builder
extension SavedView {
    private var savedFolders: some View {
        CustomScrollView(title: vm.title) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 14) {
                countHeader
                foldersGrid
            }
        }
    }

    private var countHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(vm.foldersCountText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Gradient.accent)
            Text(vm.foldersCountSuffix.lowercased())
                .font(.headline)
                .fontWeight(.regular)
                .foregroundStyle(Color.citizen.secondaryText)
            Spacer()
        }
        .fontDesign(.rounded)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    @ViewBuilder
    private var foldersGrid: some View {
        if vm.folders.isEmpty {
            EmptyFoldersView(text: vm.emptyFoldersText)
                .padding(.top, 40)
        } else {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(vm.folders) { folder in
                    folderCard(folder)
                }
            }
        }
    }

    private func folderCard(_ folder: QuestionFolder) -> some View {
        Button(action: { vm.folderPressed(folder) }) {
            VStack(alignment: .leading, spacing: 12) {
                Image.system.folder
                    .font(.title3)
                    .foregroundStyle(Gradient.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(folder.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.citizen.mainText)
                        .lineLimit(1)

                    Text(vm.questionCountText(folder))
                        .font(.caption)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(1)
                }
                .minimumScaleFactor(0.5)
            }
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15))
        .contextMenu { removeButton(folder) }
        .opacity(fadingIDs.contains(folder.id) ? 0 : 1)
        .transition(.identity)
    }

    private func removeButton(_ folder: QuestionFolder) -> some View {
        Button(role: .destructive) {
            deleteFolder(folder)
        } label: {
            Text(vm.removeActionTitle)
        }
    }
}

// MARK: - Logic
extension SavedView {
    private func deleteFolder(_ folder: QuestionFolder) {
        let id = folder.id
        let fadeDuration = 0.2

        withAnimation(.easeInOut(duration: fadeDuration)) {
            _ = fadingIDs.insert(id)
        }
        Task {
            try? await Task.sleep(for: .seconds(fadeDuration))
            withAnimation(.easeInOut(duration: 0.25)) {
                vm.remove(folder)
            }
            fadingIDs.remove(id)
        }
    }
}
