//
//  TopicPreviewView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct TopicPreviewView: View {
    let vm: QuestionsViewModel
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.citizen.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topSection
                bottomSection
            }
        }
    }
}

// MARK: - Builder
extension TopicPreviewView {

    // Верхний скруглённый блок: заголовок темы, прогресс-кольцо, статы
    private var topSection: some View {
        ZStack(alignment: .top) {
            Color.citizen.whiteAndBlack
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 16) {
                titleHeader
                ringBlock
                statsRow
            }
            .padding(.horizontal, 24)
            .padding(.top, isFaceIDPhone ? 12 : 24)
            .padding(.bottom, 20)
        }
    }

    private var titleHeader: some View {
        VStack(spacing: 8) {
            if let subtitle = vm.headerSubtitle {
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .tracking(2)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Text(vm.topicTitle)
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(Color.citizen.mainText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
        }
    }

    private var ringBlock: some View {
        ZStack {
            ProgressRing(
                progress: vm.progress,
                withPercent: false,
                lineWidth: 12
            )
            .frame(width: 220, height: 220)

            VStack(spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(vm.progressPercentText)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.citizen.mainText)
                    Text(vm.progressPercentSign)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.citizen.mainText)
                }
                Text(vm.ringCaption)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .tracking(1.5)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
        }
        .padding(.vertical, 4)
    }

    private var statsRow: some View {
        HStack(alignment: .center, spacing: 0) {
            statCell(value: vm.bestStreakText, label: vm.bestStreakLabel)
            divider
            statCell(value: vm.successfulCompletionsText, label: vm.successfulCompletionsLabel)
            divider
            statCell(value: vm.attemptsText, label: vm.attemptsLabel)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.citizen.secondaryText.opacity(0.25))
            .frame(width: 1, height: 32)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(1)
                .foregroundStyle(Color.citizen.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    // Нижняя секция: список ошибок (растягивается) + кнопки действий внизу
    private var bottomSection: some View {
        VStack(spacing: 16) {
            if !vm.wrongQuestions.isEmpty {
                toReviewHeader
                mistakesList
            } else {
                Spacer(minLength: 0)
            }

            actionButtons
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, isFaceIDPhone ? 24 : 12)
    }

    private var toReviewHeader: some View {
        HStack {
            Text(vm.toReviewHeaderText)
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(2)
                .foregroundStyle(Color.citizen.redLight)
            Spacer()
        }
    }

    private var mistakesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(vm.wrongQuestions) { question in
                    mistakeRow(question)
                    if question.id != vm.wrongQuestions.last?.id {
                        Divider().padding(.leading, 40)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func mistakeRow(_ question: Question) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.citizen.redLight.opacity(0.15))
                Image.system.xmark
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.citizen.redLight)
            }
            .frame(width: 28, height: 28)

            Text(question.number)
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.mainText)

            Spacer()
        }
        .padding(.vertical, 12)
    }

    // Матрица кнопок зависит от phase
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 10) {
            switch vm.phase {
            case .completed:
                primaryButton(title: vm.primaryActionTitle, action: dismiss)
                secondaryButton(title: vm.restartTitle, subtitle: vm.restartSubtitle, action: vm.restartTest)

            case .workingOnMistakes:
                primaryButton(title: vm.primaryActionTitle, action: vm.continueTest)
                secondaryButton(title: vm.restartTitle, subtitle: vm.restartSubtitle, action: vm.restartTest)
                ghostButton(title: vm.exitTitle, action: dismiss)

            case .inProgress:
                primaryButton(title: vm.primaryActionTitle, action: vm.continueTest)
                secondaryButton(title: vm.restartTitle, subtitle: vm.restartSubtitle, action: vm.restartTest)
                ghostButton(title: vm.exitTitle, action: dismiss)

            case .notStarted:
                EmptyView()
            }
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Gradient.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func secondaryButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption2)
                    .fontWeight(.regular)
                    .opacity(0.55)
            }
            .fontDesign(.rounded)
            .foregroundStyle(Color.citizen.mainText)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.citizen.textFieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func ghostButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
    }
}
