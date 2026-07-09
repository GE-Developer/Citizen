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
    
    init(topic: Topic) {
        _vm = StateObject(wrappedValue: QuestionsViewModel(topic: topic))
    }
    
    var body: some View {
        questionsView
            .navigationDestination(isPresented: $vm.showHint) {
                NavigationLazyView(HintView(question: vm.currentQuestion))
            }
            .sheet(isPresented: $vm.showSaveSheet) {
                SaveQuestionSheet(vm: vm)
            }
    }
}

// MARK: - Builder
extension QuestionsView {
    private var questionsView: some View {
        CustomScrollView(title: vm.testTitle, subTitle: vm.subtitle) {
            NavigationToolButton(
                vm.isCurrentQuestionSaved ? .system.bookmark : .system.bookmarkOutline,
                action: { vm.bookmarkButtonPressed() }
            )
            NavigationToolButton(
                .system.hint,
                action: { vm.hintButtonPressed() }
            )
        } content: { _ in
            progressRow
            question
                .padding(.bottom, isFaceIDPhone ? 70 : 86)
        }
        .overlay { buttonBackground }
        .overlay { resultView }
        .safeAreaInset(edge: .bottom) { continueButton }
        .overlay { preview }
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
    
    private var progressRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(vm.questionCounterText)
                .font(.caption)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(1)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundStyle(Color.citizen.secondaryText)
            ProgressBar(
                questions: vm.allTopicQuestions,
                currentQuestionID: vm.currentQuestion.id
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var question: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                questionText
                additionalText
                
                VStack {
                    ForEach(vm.displayedAnswers) { answer in
                        answerRow(answer)
                            .onTapGesture { vm.optionChanged(answer) }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .transition(
                .asymmetric(
                    insertion: .offset(x: screenWidth),
                    removal: .offset(x: -screenWidth)
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
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background {
                    ZStack {
                        Color.citizen.background
                        if vm.ctaEnabled {
                            Gradient.accent.opacity(0.7)
                        }
                    }
                }
                .foregroundStyle(Color.citizen.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
        .padding(isFaceIDPhone ? -5 : 16)
        .disabled(!vm.ctaEnabled)
        .transaction {
            $0.disablesAnimations = true
            $0.animation = nil
        }
        .background {
            Color.citizen.groupBackground
                .ignoresSafeArea()
        }
    }
    
    private var buttonBackground: some View {
        VStack {
            Spacer()
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                topTrailingRadius: 20
            )
            .frame(height: isFaceIDPhone ? 100 : 116)
            .foregroundStyle(Color.citizen.groupBackground)
            .shadow(color: Color.citizen.navBarShadow, radius: 2)
        }
        .ignoresSafeArea()
    }
    
    private var resultView: some View {
        Group {
            if vm.showSubView, let correct = vm.chosenAnswer?.isCorrect {
                VStack {
                    Spacer()
                    HStack {
                        Image.system.checkmarkAndXmark(correct)
                            .foregroundStyle(correct ? Gradient.green : Gradient.red)
                            .font(.title)
                            .fontDesign(.rounded)
                            .fontWeight(.bold)
                        VStack(alignment: .leading) {
                            Text(vm.bannerTitle)
                                .foregroundStyle(Color.citizen.mainText)
                                .font(.headline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                            
                            Text(vm.feedbackText)
                                .foregroundStyle(Color.citizen.secondaryText)
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .fontDesign(.rounded)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .minimumScaleFactor(0.6)
                    }
                    .padding()
                    .background {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            topTrailingRadius: 20
                        )
                        .foregroundStyle(Color.citizen.groupBackground)
                        .ignoresSafeArea()
                        .shadow(color: Color.citizen.viewShadow, radius: 2)
                    }
                }
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
                .id(vm.questionStep)
            }
        }
        .animation(.smooth, value: vm.showSubView)
    }
    
    @ViewBuilder
    private func answerRow(_ answer: Answer) -> some View {
        let state = vm.rowState(for: answer)
        HStack(spacing: 12) {
            if vm.showsAnswerLabels {
                Text(answer.label)
                    .font(.title3)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .foregroundStyle(Gradient.accent)
                    .frame(width: 18, alignment: .leading)
            }
            
            Text(answer.text)
                .fontDesign(.rounded)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            
            Image.system.checkmarkAndXmark(answer.isCorrect)
                .fontWeight(.semibold)
                .foregroundStyle(answer.isCorrect ? Gradient.green : Gradient.red)
                .opacity(checkmarkOpacity(for: state))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(background(for: state))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(strokeStyle(for: state), lineWidth: strokeWidth(for: state))
            }
        }
        .animation(.smooth, value: vm.showSubView)
    }
}

// MARK: - Logic
extension QuestionsView {
    private func background(for state: AnswerRowState) -> AnyShapeStyle {
        switch state {
        case .correct, .revealCorrect:
            AnyShapeStyle(Gradient.green.opacity(0.18))
        case .wrong:
            AnyShapeStyle(Gradient.red.opacity(0.18))
        case .idle, .selected:
            AnyShapeStyle(Gradient.neutral)
        }
    }
    
    private func strokeStyle(for state: AnswerRowState) -> AnyShapeStyle {
        switch state {
        case .correct, .revealCorrect:
            AnyShapeStyle(Gradient.green)
        case .wrong:
            AnyShapeStyle(Gradient.red)
        case .idle, .selected:
            AnyShapeStyle(Color.citizen.blackAndWhite)
        }
    }
    
    private func strokeWidth(for state: AnswerRowState) -> CGFloat {
        switch state {
        case .selected:
            2
        case .correct, .revealCorrect, .wrong:
            1.5
        case .idle:
            0
        }
    }
    
    private func checkmarkOpacity(for state: AnswerRowState) -> Double {
        switch state {
        case .correct, .wrong, .revealCorrect:
            1
        case .idle, .selected:
            0
        }
    }
}
