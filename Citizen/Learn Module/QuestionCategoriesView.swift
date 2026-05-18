//
//  QuestionCategoriesView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct QuestionCategoriesView: View {
    @StateObject private var vm: QuestionCategoriesViewModel

    init(category: Category) {
        _vm = StateObject(wrappedValue: QuestionCategoriesViewModel(category: category))
    }

    var body: some View {
        questionTopic
            .navigationDestination(item: $vm.chosenTopic) { topic in
                NavigationLazyView(QuestionsView(topic: topic))
            }
    }
}

// MARK: - Builder
extension QuestionCategoriesView {
    private var questionTopic: some View {
        CustomScrollView(title: vm.categoryTitle) {
            EmptyView()
        } content: { _ in
            topicsScroll
        }
    }

    private var topicsScroll: some View {
        LazyVStack(spacing: 20) {
            ForEach(vm.topics) { topic in
                topicCard(topic)
            }
        }
    }

    private func topicCard(_ topic: Topic) -> some View {
        Button(action: { vm.choose(topic) }) {
            HStack(spacing: 14) {
                ProgressRing(progress: topic.progress)

                VStack(alignment: .leading, spacing: 4) {
                    Text(topic.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.citizen.mainText)

                    Text(vm.statsDescription(for: topic))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.citizen.phase(topic.phase))

                    phasePill(topic.phase)
                }
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

                Spacer()

                Image.system.chevron
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .padding(16)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.citizen.viewShadow, radius: 4)
        }
    }

    @ViewBuilder
    private func phasePill(_ phase: TopicPhase) -> some View {
        Text(phase.pillTitle)
            .font(.callout)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Gradient.phase(phase))
            .clipShape(Capsule())
    }
}
