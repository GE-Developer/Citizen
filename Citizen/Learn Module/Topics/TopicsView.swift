//
//  TopicsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct TopicsView: View {
    @StateObject private var vm: TopicsViewModel
    
    init(category: Category) {
        _vm = StateObject(wrappedValue: TopicsViewModel(category: category))
    }
    
    var body: some View {
        questionTopic
            .navigationDestination(item: $vm.chosenTopic) { topic in
                NavigationLazyView(QuestionsView(topic: topic))
            }
    }
}

// MARK: - Builder
extension TopicsView {
    private var questionTopic: some View {
        CustomScrollView(title: vm.title, subTitle: vm.subtitle) {
            EmptyView()
        } content: { _ in
            LazyVStack(spacing: 16) {
                topicsList
            }
        }
    }
    
    private var topicsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(vm.topics) { topic in
                topicCard(topic)
            }
        }
    }
    
    private func topicCard(_ topic: Topic) -> some View {
        Button(action: { vm.choose(topic) }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text(vm.numberFor(topic))
                        .font(.title3)
                        .fontWeight(.light)
                        .foregroundStyle(Color.citizen.secondaryText)
                        .lineLimit(1)
                    
                    Text(topic.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.citizen.mainText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    pillBadge(topic)
                }
                .frame(maxHeight: .infinity)
                
                Spacer()
                
                QuestionProgressBar(questions: topic.questions)
            }
            .frame(height: 70)
            .fontDesign(.rounded)
            .padding(16)
            .background(Color.citizen.groupBackground)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: Color.citizen.viewShadow, radius: 2)
        }
    }
    
    @ViewBuilder
    private func pillBadge(_ topic: Topic) -> some View {
        let gradient = Gradient.phase(topic.phase)
        HStack(spacing: 6) {
            Circle()
                .fill(gradient)
                .frame(width: 6, height: 6)
            Text(vm.pillText(for: topic))
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(gradient)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(gradient.opacity(0.15))
        .clipShape(Capsule())
    }
    
}
