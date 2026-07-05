//
//  HintView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct HintView: View {
    @State private var vm: HintViewModel

    init(question: Question) {
        _vm = State(initialValue: HintViewModel(question: question))
    }

    var body: some View {
        hintView
            .sheet(item: $vm.selectedWord) { _ in
                WordDetailSheet(vm: vm)
            }
    }
}

// MARK: - Builder
extension HintView {
    private var hintView: some View {
        CustomScrollView(title: vm.title, subTitle: vm.subTitle) {
            EmptyView()
        } content: { _ in
            VStack(alignment: .leading, spacing: 24) {
                questionSection
                if vm.hasSentence { sentenceSection }
                answersSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(vm.questionHeader)
            RichTextView(
                segments: vm.questionSegments,
                highlightsDictionaryWords: true,
                onTapWord: vm.selectWord
            )
            .font(.title3)
            .fontWeight(.regular)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.citizen.groupBackground)
            }
            if let translation = vm.questionTranslation {
                translationText(translation)
            }
        }
    }

    private var sentenceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(vm.sentenceHeader)
            HStack(spacing: 10) {
                Capsule()
                    .frame(width: 2)
                    .foregroundStyle(Gradient.accent)
                RichTextView(
                    segments: vm.sentenceSegments,
                    highlightsDictionaryWords: true,
                    onTapWord: vm.selectWord
                )
                .font(.title3)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let translationSegments = vm.sentenceTranslationSegments {
                RichTextView(segments: translationSegments)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var answersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(vm.answersHeader)
            VStack(spacing: 10) {
                ForEach(vm.answerRows) { row in
                    answerRow(row)
                }
            }
        }
    }

    private func answerRow(_ row: HintAnswerRow) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(row.label)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Gradient.accent)
                .frame(width: 18, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                RichTextView(
                    segments: row.segments,
                    highlightsDictionaryWords: true,
                    onTapWord: vm.selectWord
                )
                .font(.title3)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)

                if let translation = row.translation {
                    Text(translation)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
            }

            Spacer(minLength: 0)

            if row.isCorrect {
                Image.system.checkmarkAndXmark(true)
                    .fontWeight(.semibold)
                    .foregroundStyle(Gradient.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.citizen.groupBackground)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .tracking(1)
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func translationText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
