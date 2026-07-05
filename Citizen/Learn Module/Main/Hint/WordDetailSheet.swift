//
//  WordDetailSheet.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct WordDetailSheet: View {
    let vm: HintViewModel

    var body: some View {
        sheetBody
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
    }
}

// MARK: - Builder
extension WordDetailSheet {
    @ViewBuilder
    private var sheetBody: some View {
        if let detail = vm.selectedWord {
            VStack(alignment: .leading, spacing: 22) {
                header(detail)
                inSentenceSection(detail)
                dictionaryFormSection(detail)
                Spacer(minLength: 0)
                saveButton(detail)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func header(_ detail: WordEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(detail.word)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.mainText)
                    Badge(detail.partOfSpeech)
                }
                Text("[\(detail.transliteration)]")
                    .font(.callout)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            Spacer(minLength: 8)
            ExitButton()
        }
    }

    @ViewBuilder
    private func inSentenceSection(_ detail: WordEntry) -> some View {
        if let translation = detail.form?.translation {
            section(vm.inSentenceHeader) {
                Text(translation)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                if let form = detail.form?.formDescription {
                    Text(form)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
            }
        }
    }

    private func dictionaryFormSection(_ detail: WordEntry) -> some View {
        section(vm.dictionaryFormHeader) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(detail.lemma.word)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                Text("[\(detail.lemma.transliteration)]")
                    .font(.callout)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            if let translation = detail.lemma.translation {
                Text(translation)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
        }
    }

    private func saveButton(_ detail: WordEntry) -> some View {
        Button(action: vm.toggleSave) {
            HStack(spacing: 8) {
                (detail.isSaved ? Image.system.checkmarkAndXmark(true) : Image.system.plus)
                Text(detail.isSaved ? vm.savedButtonTitle : vm.saveButtonTitle)
            }
            .font(.title3)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(detail.isSaved ? Gradient.green : Gradient.accent)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(1)
                .foregroundStyle(Color.citizen.secondaryText)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}
