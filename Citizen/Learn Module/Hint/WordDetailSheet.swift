//
//  WordDetailSheet.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct WordDetailSheet: View {
    private let vm: HintViewModel
    
    init(vm: HintViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        sheetBody
            .safeAreaInset(edge: .bottom) { bottomButton }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }
}

// MARK: - Builder
extension WordDetailSheet {
    @ViewBuilder
    private var sheetBody: some View {
        if let detail = vm.selectedWord {
            VStack(alignment: .leading, spacing: 10) {
                header(detail)
                lemmaSection(detail)
                inSentenceSection(detail)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    
    @ViewBuilder
    private var bottomButton: some View {
        if let detail = vm.selectedWord {
            saveButton(detail)
                .padding(.horizontal)
        }
    }
    
    private func header(_ detail: WordEntry) -> some View {
        HStack {
            Badge(detail.partOfSpeech)
            Spacer()
            ExitButton()
        }
    }
    
    private func lemmaSection(_ detail: WordEntry) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(detail.lemma.word)
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
            Text(vm.transliterationText(detail.lemma.transliteration))
                .font(.callout)
                .fontDesign(.monospaced)
                .foregroundStyle(Color.citizen.secondaryText)
            if let translation = detail.lemma.translation {
                Text(translation)
                    .font(.callout)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    @ViewBuilder
    private func inSentenceSection(_ detail: WordEntry) -> some View {
        if let form = detail.form {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Gradient.accent)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.inSentenceHeader.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .tracking(0.5)
                        .foregroundStyle(Gradient.accent)
                        .lineLimit(1)
                    Text(form.word)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.mainText)
                        .lineLimit(1)
                    Text(vm.transliterationText(form.transliteration))
                        .font(.footnote)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(1)
                    Text(form.formDescription)
                        .font(.footnote)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(2)
                    if let translation = form.translation {
                        Text(translation)
                            .font(.callout)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.citizen.mainText)
                            .lineLimit(2)
                    }
                }
                .minimumScaleFactor(0.5)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 3)
        }
    }
    
    private func saveButton(_ detail: WordEntry) -> some View {
        Button(action: vm.toggleSave) {
            HStack(spacing: 8) {
                detail.isSaved
                ? Image.system.checkmarkAndXmark(true)
                : Image.system.plus
                
                Text(detail.isSaved ? vm.savedButtonTitle : vm.saveButtonTitle)
            }
            .font(.headline)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundStyle(detail.isSaved ? Color.citizen.secondaryText : Color.citizen.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        detail.isSaved
                        ? AnyShapeStyle(Color.citizen.background)
                        : AnyShapeStyle(Gradient.accent)
                    )
            }
        }
        .transaction {
            $0.disablesAnimations = true
            $0.animation = nil
        }
    }
}
