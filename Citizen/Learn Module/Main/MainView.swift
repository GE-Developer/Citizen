//
//  MainView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var store: StoreManager
    
    @StateObject private var vm = MainViewModel()
    
    @State private var showPayWall = false
    
    var body: some View {
        learnView
            .navigationDestination(item: $vm.chosenCategory) { category in
                NavigationLazyView(TopicsView(category: category))
            }
            .navigationDestination(item: $vm.destination) { destination in
                switch destination {
                case .mistakes: NavigationLazyView(MistakesView())
                case .refresh: NavigationLazyView(RefreshView())
                case .saved: NavigationLazyView(SavedView())
                case .search: NavigationLazyView(SearchView())
                }
            }
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
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
                Divider()
                    .padding(.horizontal, 90)
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
            subtitle: vm.examReadinessTitle,
            lineWidth: 15
        )
        .padding(.horizontal, 70)
    }
    
    private var statsRow: some View {
        HStack {
            statColumn(top: vm.allTopicScore, bottom: vm.topicsTitle)
            Divider()
                .frame(height: 30)
            statColumn(top: vm.allQuestionScore, bottom: vm.questionsTitle)
            Divider()
                .frame(height: 30)
            statColumn(
                top: vm.allMistakeScore,
                bottom: vm.toReviewTitle,
                topColor: Color.citizen.accent
            )
        }
    }
    
    private var linkButtons: some View {
        HStack(spacing: 12) {
            LinkButton(
                icon: Image.system.magnifyingglass,
                title: vm.searchTitle,
                isAccent: false,
                action: { vm.searchButtonPressed() }
            )
            LinkButton(
                icon: Image.system.leaderboard,
                title: vm.leaderboardTitle,
                isAccent: true,
                action: { vm.leaderboardButtonPressed() }
            )
        }
    }
    
    private var categoriesList: some View {
        VStack(spacing: 12) {
            ForEach(vm.catalog.categories) { category in
                categoryCard(category)
            }
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
                    action: { vm.examButtonPressed() }
                )
                .premiumOption($showPayWall)
                .overlay(premiumOverlay)
                
                HomeActionCard(
                    icon: Image.system.repeatArrow,
                    color: Color.citizen.greenLight,
                    count: vm.refreshPreview,
                    title: vm.refreshTitle,
                    subtitle: vm.refreshSubtitle,
                    action: { vm.refreshButtonPressed() }
                )
            }
            
            HStack(spacing: 12) {
                HomeActionCard(
                    icon: Image.system.warning,
                    color: Color.citizen.redLight,
                    count: vm.allMistakeScore,
                    title: vm.mistakesTitle,
                    subtitle: vm.mistakesSubtitle,
                    action: { vm.mistakesButtonPressed() }
                )
                
                HomeActionCard(
                    icon: Image.system.bookmark,
                    color: Color.citizen.yellowLight,
                    count: vm.savedPreview,
                    title: vm.savedTitle,
                    subtitle: vm.savedSubtitle,
                    action: { vm.savedButtonPressed() }
                )
            }
        }
    }
    
    private var premiumOverlay: some View {
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
            
            Text(bottom.uppercased())
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
                
                ProgressBar(topics: category.topics)
            }
            .frame(height: 70)
            .padding(16)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
