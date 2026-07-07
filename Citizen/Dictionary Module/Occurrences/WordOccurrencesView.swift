//
//  WordOccurrencesView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct WordOccurrencesView: View {
    @EnvironmentObject private var store: StoreManager
    
    @State private var vm: WordOccurrencesViewModel
    @State private var showPayWall = false
    
    init(word: WordEntry) {
        _vm = State(initialValue: WordOccurrencesViewModel(word: word))
    }
    
    var body: some View {
        content
            .navigationDestination(item: $vm.selectedQuestion) { question in
                NavigationLazyView(HintView(question: question))
            }
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
    }
}

// MARK: - Builder
extension WordOccurrencesView {
    private var content: some View {
        CustomScrollView(title: vm.title, subTitle: vm.subtitle) {
            EmptyView()
        } content: { _ in
            scrollContent
        }
    }
    
    @ViewBuilder
    private var scrollContent: some View {
        if vm.rows.isEmpty {
            emptyState
        } else {
            LazyVStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text(vm.headerTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Gradient.accent)
                        .fontDesign(.rounded)
                    Text(vm.headerTransliteration)
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .fontDesign(.monospaced)
                    if let description = vm.headerDescription {
                        Text(description)
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.citizen.secondaryText)
                            .fontDesign(.rounded)
                    }
                    if let translation = vm.headerTranslation {
                        Text(translation)
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.citizen.mainText)
                            .fontDesign(.rounded)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                CustomCapsulePicker(
                    selection: $vm.selectedFilter,
                    items: vm.availableFilters,
                    capsuleName: { $0.title }
                )
                
                ForEach(vm.visibleRows) { row in
                    card(for: row)
                        .premiumOption($showPayWall, isIncluded: row.isPremium)
                        .overlay(premiumOverlay(row))
                }
            }
        }
    }
    
    private func card(for row: OccurrenceRow) -> some View {
        Button {
            vm.select(row)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                cardHeader(for: row)
                questionText(row)
                if row.hasSentence {
                    sentence(row)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    @ViewBuilder
    private func premiumOverlay(_ row: OccurrenceRow) -> some View {
        if row.isPremium {
            PremiumView(.star)
                .padding(4)
                .background {
                    Circle()
                        .fill(Color.citizen.background)
                        .shadow(color: Color.citizen.background, radius: 2)
                }
                .offset(x: 10, y: 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }
    
    private func cardHeader(for row: OccurrenceRow) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Badge(row.number)
                Spacer()
                Image.system.chevron
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            Text(row.categoryName)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Gradient.accent)
            
            Text(row.topicName)
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Gradient.accent)
        }
        .fontDesign(.rounded)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    private func questionText(_ row: OccurrenceRow) -> some View {
        Text(row.questionText)
            .font(.subheadline)
            .fontWeight(.regular)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func sentence(_ row: OccurrenceRow) -> some View {
        HStack(spacing: 10) {
            Capsule()
                .frame(width: 2)
                .foregroundStyle(Gradient.accent)
            RichTextView(segments: row.sentenceSegments, lineLimit: 3)
                .font(.subheadline)
                .fontWeight(.regular)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var emptyState: some View {
        Text(vm.emptyText)
            .font(.subheadline)
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 40)
    }
}
