//
//  SaveQuestionSheet.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SaveQuestionSheet: View {
    @ObservedObject var vm: QuestionsViewModel
    
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        sheetBody
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }
}

// MARK: - Builder
extension SaveQuestionSheet {
    private var sheetBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                Text(vm.saveSheetTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                ExitButton()
            }
            
            Text(vm.saveSheetSubtitle)
                .font(.callout)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
            
            createFolderRow
            foldersSection
        }
        .ignoresSafeArea()
        .padding(.top)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var foldersSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(vm.foldersHeader)
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(1)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            ScrollView {
                LazyVStack(spacing: 8) {
                    if vm.folders.isEmpty {
                        emptyFoldersRow
                    }
                    ForEach(vm.folders) { folder in
                        folderRow(folder)
                    }
                    Color.clear
                        .frame(height: 20)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var emptyFoldersRow: some View {
        VStack(spacing: 10) {
            Image.system.folder
                .font(.system(size: 24))
                .foregroundStyle(Color.citizen.secondaryText)
                .frame(width: 55, height: 55)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.citizen.groupBackground)
                }
            Text(vm.emptyFoldersText)
                .font(.subheadline)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    @ViewBuilder
    private var createFolderRow: some View {
        if vm.isCreatingFolder {
            newFolderField
        } else {
            newFolderButton
        }
    }
    
    
    
    
    
    
    private func folderRow(_ folder: QuestionFolder) -> some View {
        let isSaved = vm.isSaved(in: folder)
        return Button(action: { vm.toggleFolder(folder) }) {
            HStack(spacing: 12) {
                Image.system.folder
                    .font(.title3)
                    .foregroundStyle(Gradient.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(folder.name)
                        .font(.title3)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.mainText)
                    Text(vm.folderCountText(folder))
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
                Spacer()
                Image.system.checkmarkInCircle(isSaved)
                    .font(.title3)
                    .foregroundStyle(isSaved ? Gradient.green : Gradient.neutral)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.citizen.groupBackground)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var newFolderField: some View {
        HStack(spacing: 12) {
            TextField(vm.newFolderPlaceholder, text: $vm.newFolderName)
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .focused($isNameFieldFocused)
                .submitLabel(.done)
                .onSubmit { vm.createFolderAndSave() }
            Button(action: { vm.createFolderAndSave() }) {
                Image.system.checkmark
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Gradient.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.citizen.groupBackground)
        }
        .onAppear { isNameFieldFocused = true }
    }
    
    private var newFolderButton: some View {
        Button(action: { vm.startFolderCreation() }) {
            HStack(spacing: 12) {
                Image.system.plus
                    .font(.title3)
                    .foregroundStyle(Gradient.accent)
                Text(vm.newFolderTitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        Color.citizen.secondaryText.opacity(0.3),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6])
                    )
            }
        }
    }
}
