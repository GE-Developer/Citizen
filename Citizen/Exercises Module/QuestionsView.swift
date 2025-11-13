//
//  QuestionsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CircularProgressView: View {
    @State private var progress = 0.0
    
    private var progresss: Double
    private var percentProgress: String
    
    init(progresss: Double) {
        self.progresss = progresss
        self.percentProgress = "\(Int(progresss * 100))%"
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.citizen.grayLight, lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Gradient.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
//                .animation(.bouncy.delay(0.7), value: progress)
            
//            Text()
        }
        .frame(width: 120)
        
        .onAppear {
            withAnimation(.bouncy.speed(0.4).delay(0.5)) {
                progress = progresss
            }
        }
        
        .background {
            Color.green
        }
    }
}

struct QuestionsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: QuestionsViewModel
    
    init(_ questions: [Question]) {
        _vm = StateObject(wrappedValue: QuestionsViewModel(questions))
    }
    
    var body: some View {
        CustomScrollView { _ in
            ProgressView(value: vm.progress)
                .tint(Gradient.accent)
            Spacer()
            NavigationToolButton(.system.privacyPolicy, action: {})
        } scrollView: { _ in
            questionsView
                .padding(.horizontal)
                .padding(.bottom, isFaceIDPhone ? 70 : 86)
        }
        .scrollIndicators(.never)
        .overlay { buttonBackground }
        .overlay { resultView }
        .safeAreaInset(edge: .bottom) { continueButton }
        .overlay { preview }
        .animation(.smooth.speed(1.5), value: vm.showSubView)
        .animation(.smooth, value: vm.showPreview)
    }
    
    @ViewBuilder
    private var preview: some View {
        if vm.showPreview {
            CustomPage {
                Spacer()
            } content: {
                VStack(spacing: 30) {
                    Text(vm.startViewTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(Color.citizen.mainText)
                    
                    VStack {
                        HStack {
                            Text("Категория вопросов:")
                                .font(.headline)
                                .fontWeight(.light)
                                .fontDesign(.rounded)
                            Text(vm.currentQuestion.category.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .textCase(.uppercase)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Gradient.accent)
                                }
                            Spacer()
                        }
                        
                        HStack {
                            Text("Тема:")
                                .font(.headline)
                                .fontWeight(.light)
                                .fontDesign(.rounded)
                            Text(vm.currentQuestion.theme.name)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .textCase(.uppercase)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Gradient.accent)
                                }
                            Spacer()
                        }
                        
                        HStack {
                            Text("Количество вопросов:")
                                .font(.headline)
                                .fontWeight(.light)
                                .fontDesign(.rounded)
                            Text(vm.questionsCount.formatted())
                                .font(.caption)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .textCase(.uppercase)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Gradient.accent)
                                }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
         
                    CircularProgressView(progresss: vm.progress)
                        .frame(width: 120, height: 120)
                    
                    Spacer()
                    
                    VStack {
                        Button(action: vm.continueTest) {
                            Text("Продолжить")
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background { Gradient.accent }
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: vm.restartTest) {
                            VStack {
                                Text("Начать сначала")
                                Text("Прогресс будет сброшен")
                                    .font(.caption)
                                    .fontWeight(.regular)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background { Color.black }
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                        }

                        Button(action: { dismiss() }) {
                            Text("Выйти")
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .foregroundStyle(Color.citizen.secondaryText)
                        }
                    }
                    .font(.title3)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    

}

// MARK: - Builder
extension QuestionsView {
    private var questionsView: some View {
        VStack(spacing: 20) {
            topic
            questionText
            
            VStack {
                ForEach(vm.currentQuestion.options) { option in
                    question(option)
                        .onTapGesture { vm.optionChanged(option) }
                }
            }
        }
        .id(vm.currentQuestion.id)
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        )
        .animation(.smooth, value: vm.currentQuestion.id)
        
    }
    
    private var topic: some View {
        Text(vm.currentQuestion.topic.description)
            .font(.headline)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.black)
                    .shadow(color: .gray.opacity(0.5), radius: 1)
            }
    }
    
    @ViewBuilder
    private var questionText: some View {
        if let text = vm.currentQuestion.text {
            HStack {
                Text(L10nGE(text))
                    .font(.title3)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .minimumScaleFactor(0.5)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .overlay {
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 3)
                        .foregroundStyle(Gradient.accent)
                    Spacer()
                }
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: vm.buttonPressed) {
            Text("Продолжить")
                .font(.title3)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background { Color.black }
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.citizen.background.opacity(0.3), radius: 5)
        }
        .padding(.horizontal)
        .padding(isFaceIDPhone ? -5 : 16)
        .disabled(vm.continueButtonDisabled)
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
            .shadow(color: Color.citizen.navBarShadow, radius: 5)

        }
        .ignoresSafeArea()
    }
        
        
    
    
    private var resultView: some View {
        Group {
            if vm.showSubView {
                if let correct = vm.chosenOption?.isCorrect {
                    VStack {
                        Spacer()
                        HStack {
                            Image.system.checkmarkAndXmark(correct)
                                .foregroundStyle(correct ? Gradient.green : Gradient.accent)
                            .font(.title)
                            .fontDesign(.rounded)
                            .fontWeight(.bold)
                            Text(vm.subViewTitle)
                                .foregroundStyle(Color.white)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            Spacer()
                        }
                        .padding()
                        .background {
                            UnevenRoundedRectangle(
                                topLeadingRadius: 20,
                                topTrailingRadius: 20
                            )
                            .fill(Color.black)
                            .ignoresSafeArea()
                            .shadow(color: .black.opacity(0.5), radius: 4)
                        }
                    }
                    .transition(.move(edge: .bottom))
                    
                }
            }
        }
    }
    
    private func question(_ option: Option) -> some View {
        HStack {
            Text(L10nGE(option.id))
                .fontDesign(.rounded)
                .minimumScaleFactor(0.5)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(color(option))
                    .opacity(0.5)
                    
                stroke(for: option)
            }
        }
    }
    
    private func stroke(for option: Option) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(
                Color.blackAndWhite,
                lineWidth: vm.chosenOption == option ? 2 : 0
            )
        
    }
    
    private func color(_ option: Option) -> LinearGradient {
        guard vm.showSubView else { return Gradient.gray }
        
        if option.isCorrect {
            return Gradient.green
        }
        
        if vm.chosenOption == option && !option.isCorrect {
            return Gradient.accent
        }
        
        return Gradient.gray
    }
    
}
