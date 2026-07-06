//
//  QuestionsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct QuestionsView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm: QuestionsViewModel
    @State private var showHint = false

    init(topic: Topic) {
        _vm = StateObject(wrappedValue: QuestionsViewModel(topic: topic))
    }

    var body: some View {
        questionsView
    }
}

// MARK: - Builder
extension QuestionsView {
    private var questionsView: some View {
        CustomScrollView(title: vm.testTitle, subTitle: vm.currentQuestion.number) {
            NavigationToolButton(.system.bookmark, action: {})
            NavigationToolButton(.system.hint, action: { showHint = true })
        } content: { _ in
            progressRow
            question
                .padding(.bottom, isFaceIDPhone ? 70 : 86)
        }
        .overlay { buttonBackground }
        .overlay { resultView }
        .safeAreaInset(edge: .bottom) { continueButton }
        .overlay { preview }
        .navigationDestination(isPresented: $showHint) {
            NavigationLazyView(HintView(question: vm.currentQuestion))
        }
    }

    private var progressRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(vm.questionCounterText)
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(1)
                .foregroundStyle(Color.citizen.secondaryText)
            QuestionProgressBar(
                questions: vm.allTopicQuestions,
                currentQuestionID: vm.currentQuestion.id
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var preview: some View {
        Group {
            if vm.showPreview {
                TopicPreviewView(vm: vm, dismiss: { dismiss() })
                    .transition(
                        .move(edge: .bottom)
                        .combined(with: .opacity)
                    )
            }
        }
        .animation(.smooth, value: vm.showPreview)
    }

    private var question: some View {
        Group {
            VStack(spacing: 20) {
                questionText
                additionalText

                VStack {
                    ForEach(vm.currentQuestion.answers) { answer in
                        answerRow(answer)
                            .onTapGesture { vm.optionChanged(answer) }
                    }
                }
            }
            .transition(
                .asymmetric(
                    insertion: .horizontalShift(x: 1000),
                    removal: .horizontalShift(x: -1000)
                )
            )
            .id(vm.questionStep)
        }
        .animation(.smooth, value: vm.questionStep)
    }

    private var questionText: some View {
        Text(vm.currentQuestion.question)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title3)
            .fontWeight(.regular)
            .fontDesign(.rounded)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.citizen.mainText)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.citizen.groupBackground)
            }
    }

    @ViewBuilder
    private var additionalText: some View {
        if vm.currentQuestion.additionalText != nil {
            HStack(spacing: 10) {
                Capsule()
                    .frame(width: 2)
                    .foregroundStyle(Gradient.accent)
                RichTextView(segments: vm.additionalTextSegments)
                    .font(.title3)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
        }
    }

    private var continueButton: some View {
        Button(action: vm.buttonPressed) {
            Text(vm.ctaTitle)
                .font(.title3)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background { Color.citizen.background }
                .foregroundStyle(Color.citizen.mainText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(isFaceIDPhone ? -5 : 16)
        .opacity(vm.ctaEnabled ? 1 : 0.5)
        .disabled(!vm.ctaEnabled)
    }

    private var buttonBackground: some View {
        VStack {
            Spacer()
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                topTrailingRadius: 20
            )
            .frame(height: isFaceIDPhone ? 100 : 116)
            .foregroundStyle(.ultraThinMaterial)
            .shadow(color: Color.citizen.navBarShadow, radius: 4)
        }
        .ignoresSafeArea()
    }

    private var resultView: some View {
        Group {
            if vm.showSubView, let correct = vm.chosenAnswer?.isCorrect {
                VStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Image.system.checkmarkAndXmark(correct)
                                .foregroundStyle(correct ? Gradient.green : Gradient.accent)
                                .font(.title)
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                            Text(vm.bannerTitle)
                                .foregroundStyle(Color.citizen.mainText)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            Spacer()
                        }
                        Text(vm.feedbackText)
                            .foregroundStyle(Color.citizen.mainText)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                    }
                    .padding()
                    .background {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            topTrailingRadius: 20
                        )
                        .fill(Color.citizen.whiteAndBlack)
                        .ignoresSafeArea()
                        .shadow(color: Color.citizen.viewShadow, radius: 4)
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smooth.speed(1.5), value: vm.showSubView)
    }

    private func answerRow(_ answer: Answer) -> some View {
        let state = vm.rowState(for: answer)
        return HStack(alignment: .top, spacing: 12) {
            Text(answer.label)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(Gradient.accent)
                .frame(width: 18, alignment: .leading)

            Text(answer.text)
                .fontDesign(.rounded)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)

            checkmark(for: state)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(background(for: state))
                stroke(for: state)
            }
        }
        .animation(nil, value: vm.chosenAnswer)
        .animation(.smooth, value: vm.showSubView)
    }

    private func stroke(for state: AnswerRowState) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(
                Color.citizen.blackAndWhite,
                lineWidth: state == .selected ? 2 : 0
            )
    }

    private func checkmark(for state: AnswerRowState) -> some View {
        Image.system.checkmarkAndXmark(state == .correct || state == .revealCorrect)
            .opacity(checkmarkOpacity(for: state))
    }
}

// MARK: - Logic
extension QuestionsView {
    private func background(for state: AnswerRowState) -> LinearGradient {
        switch state {
        case .correct, .revealCorrect: Gradient.green
        case .wrong:                   Gradient.red
        case .idle, .selected:         Gradient.neutral
        }
    }

    private func checkmarkOpacity(for state: AnswerRowState) -> Double {
        switch state {
        case .correct, .wrong, .revealCorrect: 1
        case .idle, .selected:                 0
        }
    }
}

private extension AnyTransition {
    static func horizontalShift(x: CGFloat) -> AnyTransition {
        .modifier(
            active: HorizontalShiftModifier(x: x),
            identity: HorizontalShiftModifier(x: 0)
        )
    }
}

private struct HorizontalShiftModifier: ViewModifier {
    let x: CGFloat
    func body(content: Content) -> some View {
        content.offset(x: x)
    }
}
