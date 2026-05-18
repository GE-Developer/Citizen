//
//  QuestionsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct QuestionsView: View {
    // Нужен чтобы вызвать dismiss() из TopicPreviewView (кнопка "Выйти")
    @Environment(\.dismiss) private var dismiss
    // @StateObject — создаётся один раз при первом рендере, переживает обновления View
    @StateObject private var vm: QuestionsViewModel

    init(topic: Topic) {
        _vm = StateObject(wrappedValue: QuestionsViewModel(topic: topic))
    }

    var body: some View {        
        CustomScrollView(title: "vm.title") {
            NavigationToolButton(.system.privacyPolicy, action: {})
        } content: { _ in
            ProgressView(value: vm.progress)
                .tint(Gradient.accent)
            questionsView
                .padding(.horizontal)
                .padding(.bottom, isFaceIDPhone ? 70 : 86)
        }
        
        .scrollIndicators(.never)
        .overlay { buttonBackground }  // размытый фон под кнопкой "Продолжить"
        .overlay { resultView }        // плашка "Правильно/Неправильно" снизу
        .safeAreaInset(edge: .bottom) { continueButton }  // плавающая кнопка над safe area
        .overlay {
            // Превью-экран поверх всего — показывается при inProgress/workingOnMistakes/completed
            if vm.showPreview {
                TopicPreviewView(vm: vm, dismiss: { dismiss() })
                    .transition(.move(edge: .bottom).combined(with: .opacity))  // появляется снизу
            }
        }
        .animation(.smooth.speed(1.5), value: vm.showSubView)  // анимация плашки результата
        .animation(.smooth, value: vm.showPreview)             // анимация превью-экрана
    }
}

// MARK: - Builder
extension QuestionsView {

    // Вопрос + варианты ответа; .id(questionStep) заставляет SwiftUI пересоздавать View при каждом шаге → срабатывает transition
    private var questionsView: some View {
        VStack(spacing: 20) {
            questionPrompt   // текст вопроса
            additionalText   // дополнительный контекст (если есть)

            VStack {
                ForEach(vm.currentQuestion.answers) { answer in
                    answerRow(answer)
                        .onTapGesture { vm.optionChanged(answer) }  // передаём выбор в ViewModel
                }
            }
        }
        .id(vm.questionStep)  // уникальный id на каждый шаг — SwiftUI удаляет старый View и вставляет новый с анимацией
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing),  // новый вопрос въезжает справа
                removal: .move(edge: .leading)      // старый вопрос уезжает влево
            )
        )
        .animation(.smooth, value: vm.questionStep)  // анимация привязана к шагу
    }

    // Тёмный прямоугольник с текстом вопроса
    private var questionPrompt: some View {
        Text(vm.currentQuestion.question)
            .font(.headline)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.5)  // уменьшает шрифт если не влезает
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

    // Дополнительный текст вопроса с акцентной полоской слева; не показывается если пустой
    @ViewBuilder
    private var additionalText: some View {
        if !vm.currentQuestion.additionalText.isEmpty {
            HStack {
                Text(vm.currentQuestion.additionalText)
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
                    // Вертикальная акцентная полоска слева — визуальный якорь для цитаты
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 3)
                        .foregroundStyle(Gradient.accent)
                    Spacer()
                }
            }
        }
    }

    // Плавающая кнопка "Продолжить" внизу экрана
    private var continueButton: some View {
        Button(action: vm.buttonPressed) {
            Text(L10n("Продолжить"))
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
        .padding(isFaceIDPhone ? -5 : 16)  // компенсируем safe area на Face ID устройствах
        .disabled(vm.continueButtonDisabled)  // задизейблена пока не выбран ответ
    }

    // Полупрозрачный фон под кнопкой "Продолжить" — размывает контент снизу
    private var buttonBackground: some View {
        VStack {
            Spacer()
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                topTrailingRadius: 20  // скруглены только верхние углы
            )
            .frame(height: isFaceIDPhone ? 100 : 116)
            .foregroundStyle(.ultraThinMaterial)  // стеклянный эффект
            .shadow(color: Color.citizen.navBarShadow, radius: 5)
        }
        .ignoresSafeArea()
    }

    // Плашка результата ответа — появляется снизу поверх всего
    private var resultView: some View {
        Group {
            if vm.showSubView {
                if let correct = vm.chosenAnswer?.isCorrect {
                    VStack {
                        Spacer()
                        HStack {
                            // Иконка галочки или крестика в зависимости от правильности
                            Image.system.checkmarkAndXmark(correct)
                                .foregroundStyle(correct ? Gradient.green : Gradient.accent)
                                .font(.title)
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                            // "Правильно" или "Неправильно"
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
                    .transition(.move(edge: .bottom))  // появляется снизу вверх
                }
            }
        }
    }

    // Строка одного варианта ответа с цветовой подсветкой после выбора
    private func answerRow(_ answer: Answer) -> some View {
        HStack {
            Text(answer.text)
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
                    .foregroundStyle(color(answer))  // серый → зелёный/красный после ответа
                    .opacity(0.5)
                stroke(for: answer)  // рамка вокруг выбранного варианта
            }
        }
    }
}

// MARK: - Logic
extension QuestionsView {

    // Рамка вокруг выбранного варианта ответа; ширина 0 если не выбран
    private func stroke(for answer: Answer) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(
                Color.blackAndWhite,
                lineWidth: vm.chosenAnswer == answer ? 2 : 0
            )
    }

    // Цвет фона варианта ответа: серый до ответа, зелёный/красный после
    private func color(_ answer: Answer) -> LinearGradient {
        guard vm.showSubView else { return Gradient.gray }  // ответ ещё не зафиксирован — все серые
        if answer.isCorrect { return Gradient.green }       // правильный вариант — зелёный
        if vm.chosenAnswer == answer { return Gradient.accent }  // выбранный неправильный — акцентный (красный)
        return Gradient.gray  // остальные варианты — серые
    }
}
