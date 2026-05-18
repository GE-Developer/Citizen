//
//  LearnView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct LearnView: View {
    @StateObject private var vm = LearnViewModel()
    
    private var mistakeCountColor: Color {
        vm.catalog.mistakePoolCount > 0
        ? Color.citizen.redLight
        : Color.citizen.greenLight
    }
    
    var body: some View {
        learnView
            .navigationDestination(item: $vm.chosenCategory) { category in
                NavigationLazyView(QuestionCategoriesView(category: category))
            }
    }
}

// MARK: - Builder
extension LearnView {
    private var learnView: some View {
        CustomScrollView(tabBarIsVisible: true) { _ in
            LazyVStack(spacing: 25) {
                header
                statsRow
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
                topColor: mistakeCountColor
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
    
    private var categoriesList: some View {
        VStack(spacing: 12) {
            ForEach(vm.catalog.categories) { category in
                categoryCard(category)
            }
        }
    }
    
    private func categoryCard(_ category: Category) -> some View {
        Button(action: { vm.choose(category) }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(vm.numberFor(category))
                        .font(.title3)
                        .fontWeight(.light)
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
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
                            .foregroundStyle(Color.citizen.progress(category.progress))
                        
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
                
                topicDotsRow(
                    completed: category.completedTopics,
                    total: category.totalTopics,
                    progress: category.progress
                )
            }
            .frame(height: 70)
            .padding(16)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.citizen.viewShadow, radius: 2)
        }
    }
    
    private func topicDotsRow(completed: Int, total: Int, progress: Double) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(
                        i < completed
                        ? Color.citizen.progress(progress)
                        : Color.citizen.background
                    )
                    .frame(height: 8)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HomeActionCard(
                    icon: Image.system.timer,
                    сolor: Color.citizen.secondaryText,
                    count: vm.examPreview,
                    title: vm.examTitle,
                    subtitle: vm.examSubtitle,
                    action: { vm.examButtonPressed() })
                
                HomeActionCard(
                    icon: Image.system.repeatArrow,
                    сolor: Color.citizen.greenLight,
                    count: vm.refreshPreview,
                    title: vm.refreshTitle,
                    subtitle: vm.refreshSubtitle,
                    action: { vm.refreshButtonPressed() })
            }
            
            HStack(spacing: 12) {
                HomeActionCard(
                    icon: Image.system.warning,
                    сolor: Color.citizen.redLight,
                    count: vm.allMistakeScore,
                    title: vm.mistakesTitle,
                    subtitle: vm.mistakesSubtitle,
                    action: { vm.mistakesButtonPressed() })
                
                HomeActionCard(
                    icon: Image.system.bookmark,
                    сolor: Color.citizen.yellowLight,
                    count: vm.savedPreview,
                    title: vm.savedTitle,
                    subtitle: vm.savedSubtitle,
                    action: { vm.savedButtonPressed() })
            }
        }
    }
}
