//
//  MainView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct MainView: View {
    @StateObject private var vm = MainViewModel()

    var body: some View {
        learnView
            .navigationDestination(item: $vm.chosenCategory) { category in
                NavigationLazyView(TopicsView(category: category))
            }
    }
}

// MARK: - Builder
extension MainView {
    private var learnView: some View {
        CustomScrollView(tabBarIsVisible: true) { _ in
            LazyVStack(spacing: 25) {
                header
                statsRow
                linkButtons
                categoriesList
                Divider()
                    .padding(.horizontal, 90)
                actionButtons
            }
            .padding(.top, 20)
        }
    }
    
    private var header: some View {
        ProgressRing(
            progress: vm.catalog.progress,
            subtitle: vm.examReadinessTitle.uppercased(),
            lineWidth: 15
        )
        .padding(.horizontal, 70)
    }
    
    private var statsRow: some View {
        HStack {
            statColumn(top: vm.allTopicScore, bottom: vm.topicsTitle.uppercased())
            Divider()
                .frame(height: 30)
            statColumn(top: vm.allQuestionScore, bottom: vm.questionsTitle.uppercased())
            Divider()
                .frame(height: 30)
            statColumn(
                top: vm.allMistakeScore,
                bottom: vm.toReviewTitle.uppercased(),
                topColor: Color.citizen.accent
            )
        }
    }
    
    private func statColumn(
        top: String,
        bottom: String,
        topColor: Color = Color.citizen.mainText
    ) -> some View {
        VStack(spacing: 4) {
            Text(top)
                .font(.headline)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(topColor)
            
            Text(bottom)
                .font(.caption2)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    // Прямоугольные кнопки одинаковой ширины и высоты (пока без навигации).
    // «Лидерборд» — акцентная (тон + обводка), как кнопка перехода на алфавит.
    private var linkButtons: some View {
        HStack(spacing: 12) {
            linkButton(
                icon: Image.system.magnifyingglass,
                title: vm.searchTitle,
                isAccent: false,
                action: { vm.searchButtonPressed() }
            )
            linkButton(
                icon: Image.system.leaderboard,
                title: vm.leaderboardTitle,
                isAccent: true,
                action: { vm.leaderboardButtonPressed() }
            )
        }
    }

    private func linkButton(
        icon: Image,
        title: String,
        isAccent: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                icon
                    .font(.headline)
                    .foregroundStyle(
                        isAccent
                        ? AnyShapeStyle(Gradient.accent)
                        : AnyShapeStyle(Color.citizen.secondaryText)
                    )
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.mainText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.citizen.groupBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Gradient.accent.opacity(isAccent ? 0.12 : 0))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Gradient.accent.opacity(isAccent ? 0.45 : 0), lineWidth: 1)
            }
        }
    }

    private var categoriesList: some View {
        VStack(spacing: 12) {
            ForEach(vm.catalog.categories) { category in
                categoryCard(category)
            }
        }
    }
    
    private func categoryCard(_ category: Category) -> some View {
        Button(action: { vm.choose(category) }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(vm.numberFor(category))
                        .font(.title3)
                        .fontWeight(.light)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(1)

                    Text(vm.titleFor(category))
                        .font(.headline)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.mainText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(vm.percentProgressFor(category))
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.citizen.accent)

                        Text(vm.topicScoreFor(category))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.citizen.secondaryText)
                            .tracking(0.5)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                }
                .frame(maxHeight: .infinity)

                Spacer()

                topicDotsRow(topics: category.topics)
            }
            .frame(height: 70)
            .padding(16)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    private func topicDotsRow(topics: [Topic]) -> some View {
        HStack(spacing: 4) {
            ForEach(topics) { topic in
                Capsule()
                    .fill(topicCapsuleStyle(for: topic.phase))
                    .frame(height: 8)
            }
        }
    }

    private func topicCapsuleStyle(for phase: TopicPhase) -> AnyShapeStyle {
        switch phase {
        case .completed:               return AnyShapeStyle(Gradient.green)
        case .workingOnMistakes:       return AnyShapeStyle(Gradient.red)
        case .notStarted, .inProgress: return AnyShapeStyle(Color.citizen.background)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HomeActionCard(
                    icon: Image.system.timer,
                    color: Color.citizen.secondaryText,
                    count: vm.examPreview,
                    title: vm.examTitle,
                    subtitle: vm.examSubtitle,
                    action: { vm.examButtonPressed() })
                
                HomeActionCard(
                    icon: Image.system.repeatArrow,
                    color: Color.citizen.greenLight,
                    count: vm.refreshPreview,
                    title: vm.refreshTitle,
                    subtitle: vm.refreshSubtitle,
                    action: { vm.refreshButtonPressed() })
            }
            
            HStack(spacing: 12) {
                HomeActionCard(
                    icon: Image.system.warning,
                    color: Color.citizen.redLight,
                    count: vm.allMistakeScore,
                    title: vm.mistakesTitle,
                    subtitle: vm.mistakesSubtitle,
                    action: { vm.mistakesButtonPressed() })
                
                HomeActionCard(
                    icon: Image.system.bookmark,
                    color: Color.citizen.yellowLight,
                    count: vm.savedPreview,
                    title: vm.savedTitle,
                    subtitle: vm.savedSubtitle,
                    action: { vm.savedButtonPressed() })
            }
        }
    }
}
