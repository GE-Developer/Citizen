//
//  TopicPreviewView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

// Полноэкранный overlay поверх QuestionsView — показывается при inProgress/workingOnMistakes/completed
struct TopicPreviewView: View {
    let vm: QuestionsViewModel     // ViewModel теста — берём из него всю информацию
    let dismiss: () -> Void        // closure для выхода назад (передаётся из QuestionsView)

    var body: some View {
        ZStack {
            Color.citizen.background.ignoresSafeArea()  // фоновый цвет на весь экран
            VStack(spacing: 0) {
                heroCard       // верхняя градиентная секция с визуальным акцентом
                bottomSection  // нижняя секция со статистикой и кнопками
            }
        }
    }
}

// MARK: - Builder
extension TopicPreviewView {

    // Верхняя секция — градиентная карточка со скруглёнными нижними углами
    private var heroCard: some View {
        ZStack {
            heroGradient
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40))
                .ignoresSafeArea(edges: .top)  // градиент доходит до верхнего края экрана

            VStack(spacing: 20) {
                topicChip   // название темы в капсуле
                heroVisual  // главный визуальный элемент (кольцо / число / галочка)
                // Заголовок фазы — nil у notStarted, поэтому не показываем
                if let title = vm.phase.previewTitle {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 44)
        }
    }

    // Цвет градиента зависит от фазы: зелёный при completed, акцентный в остальных
    private var heroGradient: LinearGradient {
        vm.phase == .completed ? Gradient.green : Gradient.accent
    }

    // Капсула с названием темы поверх градиента
    private var topicChip: some View {
        Text(vm.topicTitle)
            .font(.subheadline)
            .fontWeight(.medium)
            .fontDesign(.rounded)
            .foregroundStyle(.white.opacity(0.9))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(.white.opacity(0.2)))  // полупрозрачный белый фон
    }

    // Центральный визуальный элемент — зависит от фазы
    @ViewBuilder
    private var heroVisual: some View {
        switch vm.phase {
        case .inProgress:
            // Анимированное кольцо с процентом прогресса
            PreviewProgressRing(progress: vm.progress)
        case .workingOnMistakes:
            // Большое число ошибок
            mistakesBadge
        case .completed:
            // Большая галочка в круге
            Image.system.checkmarkInCircle()
                .font(.system(size: 72))
                .foregroundStyle(.white)
        case .notStarted:
            EmptyView()  // не используется — превью не показывается при notStarted
        }
    }

    // Число ошибок крупным шрифтом с подписью
    private var mistakesBadge: some View {
        VStack(spacing: 4) {
            Text("\(vm.mistakesRemaining)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text("ошибок для разбора")
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    // Нижняя секция: статистика + кнопки
    private var bottomSection: some View {
        VStack(spacing: 20) {
            statsRow  // карточки с цифрами
            Spacer()
            actionButtons  // кнопки действий
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, isFaceIDPhone ? 12 : 24)
    }

    // Горизонтальный ряд карточек со статистикой — состав зависит от фазы
    @ViewBuilder
    private var statsRow: some View {
        switch vm.phase {
        case .inProgress:
            HStack(spacing: 10) {
                statCard(value: "\(vm.correctCount)", label: "правильно", accent: Color.citizen.greenLight)
                // questionsCount - correctCount = количество ещё не закрытых вопросов
                statCard(value: "\(vm.questionsCount - vm.correctCount)", label: "осталось", accent: Color.citizen.accentLight)
                statCard(value: "\(vm.questionsCount)", label: "всего", accent: Color.citizen.grayDark)
            }
        case .workingOnMistakes:
            HStack(spacing: 10) {
                statCard(value: "\(vm.correctCount)", label: "правильно", accent: Color.citizen.greenLight)
                // mistakesRemaining = pendingQuestions.count — сколько ошибок в очереди
                statCard(value: "\(vm.mistakesRemaining)", label: "ошибок", accent: Color.citizen.accentLight)
                statCard(value: "\(vm.questionsCount)", label: "всего", accent: Color.citizen.grayDark)
            }
        case .completed:
            HStack(spacing: 10) {
                statCard(value: "\(vm.correctCount)", label: "правильно", accent: Color.citizen.greenLight)
                statCard(value: "\(vm.questionsCount)", label: "вопросов", accent: Color.citizen.grayDark)
            }
        case .notStarted:
            EmptyView()
        }
    }

    // Карточка одной цифры: большое число + подпись
    private func statCard(value: String, label: String, accent: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(accent)  // цвет числа передаётся снаружи
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.citizen.textFieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // Кнопки действий — набор зависит от фазы
    private var actionButtons: some View {
        VStack(spacing: 10) {
            // Основная кнопка: "Продолжить" / "Разобрать ошибки" / "Пройти заново"
            // primaryActionTitle возвращает nil при notStarted — тогда кнопки нет
            if let title = vm.phase.primaryActionTitle {
                // При completed рестартуем, в остальных случаях продолжаем
                let action = vm.phase == .completed ? vm.restartTest : vm.continueTest
                primaryButton(title: title, action: action)
            }
            // Кнопка "Начать сначала" только в активных фазах (не при completed)
            if vm.phase == .inProgress || vm.phase == .workingOnMistakes {
                secondaryButton(title: vm.restartTitle, subtitle: vm.restartSubtitle, action: vm.restartTest)
            }
            // Кнопка "Выйти" — всегда показывается
            ghostButton(title: vm.exitTitle, action: dismiss)
        }
    }

    // Акцентная кнопка с градиентным фоном
    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Gradient.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // Вторичная кнопка с тихим фоном и подписью
    private func secondaryButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                Text(subtitle)
                    .font(.caption2)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .opacity(0.55)  // приглушаем подпись
            }
            .foregroundStyle(Color.citizen.mainText)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.citizen.textFieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // Текстовая кнопка без фона
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

// Кольцо прогресса для превью-экрана (inProgress фаза) — белое на акцентном фоне
// Использует кастомный белый градиент поверх акцентного фона hero-карточки
private struct PreviewProgressRing: View {
    let progress: Double

    private let size: CGFloat = 160
    private let lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.25), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Gradient.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}
