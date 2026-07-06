//
//  QuestionsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

@MainActor
final class QuestionsViewModel: ObservableObject {

    // MARK: - @PropertyWrappers
    @Published var chosenAnswer: Answer?

    @Published private(set) var currentQuestion: Question
    @Published private(set) var questionStep: Int = 0
    @Published private(set) var correctCount: Int
    @Published private(set) var showSubView = false
    @Published private(set) var showPreview: Bool
    @Published private(set) var feedbackText: String = ""
    @Published private(set) var phase: TopicPhase
    @Published private(set) var attempts: Int = 0
    @Published private(set) var sessionBestStreak: Int = 0
    @Published private(set) var successfulCompletions: Int = 0

    @Published private var pendingQuestions: [Question]

    // MARK: - var

    var progress: Double { Double(correctCount) / Double(questionsCount) }

    // Порядковый номер текущего вопроса из JSON (1-based).
    var currentQuestionIndex: Int { currentQuestion.index }

    // Live-снимок всех вопросов темы — для capsule progress bar.
    var allTopicQuestions: [Question] {
        repository.topic(byID: topicID)?.questions ?? []
    }

    // Состояние CTA-кнопки внизу экрана: idle → selected → checked
    var ctaTitle: String {
        if showSubView { return continueButtonTitle }
        if chosenAnswer == nil { return selectAnswerTitle }
        return checkAnswerTitle
    }
    var ctaEnabled: Bool { showSubView || chosenAnswer != nil }
    var bannerTitle: String { (chosenAnswer?.isCorrect ?? false) ? "Correct" : "Not Quite" }
    var questionCounterText: String {
        String(format: questionCounterFormat, currentQuestionIndex, questionsCount)
    }

    var additionalTextSegments: [RichTextSegment] {
        (currentQuestion.additionalText ?? "").asRichSegments
    }

    var progressPercentText: String { "\(Int(progress * 100))" }

    var bestStreakText: String { "\(sessionBestStreak)" }
    var attemptsText: String { "\(attempts)" }
    var successfulCompletionsText: String { "\(successfulCompletions)" }

    var headerSubtitle: String? { phase.statusLabel }
    var ringCaption: String { "\(correctCount) ИЗ \(questionsCount) ПРАВИЛЬНО" }
    var wrongQuestions: [Question] {
        guard let topic = repository.topic(byID: topicID) else { return [] }
        return topic.questions.filter { $0.status == .wrong }
    }
    var primaryActionTitle: String { phase.primaryActionTitle(mistakesCount: mistakesCount) ?? "" }
    var toReviewHeaderText: String { "ОШИБКИ · \(mistakesCount) ВОПРОСОВ" }

    // MARK: - private var
    private var mistakesCount: Int { wrongQuestions.count }
    private var wrongInPool: Set<String>
    private var currentStreak: Int = 0
    private var roundSize: Int = 0
    private var visitedInRound: Int = 0

    // MARK: - let

    let topicTitle: String
    let questionsCount: Int
    let restartTitle = "Начать сначала"
    let restartSubtitle = "Прогресс будет сброшен"
    let exitTitle = "Выйти"
    let progressPercentSign = "%"

    let bestStreakLabel = "ЛУЧШАЯ СЕРИЯ"
    let successfulCompletionsLabel = "ПРОЙДЕНО"
    let attemptsLabel = "ПОПЫТКА"

    // Тексты экрана вопроса (новый дизайн, английский — без L10n)
    let questionCounterFormat = "QUESTION %d OF %d"
    let selectAnswerTitle     = "Select an answer"
    let checkAnswerTitle      = "Check answer"
    let continueButtonTitle   = "Continue  →"
    let testTitle             = "Question"

    // MARK: - private let

    private let topicID: String
    private let haptic = HapticsManager.shared
    private let repository = QuizRepository.shared
    private let statsStorage = TopicStatsStorage.shared

    // MARK: - init

    init(topic: Topic) {
        self.topicID = topic.id
        self.topicTitle = topic.name
        self.questionsCount = topic.questions.count

        let current = QuizRepository.shared.topic(byID: topic.id) ?? topic
        let questions = current.questions
        let wrongIDs = Set(questions.filter { $0.status == .wrong }.map(\.id))
        let phase = current.phase

        self.phase = phase
        self.correctCount = questions.filter { $0.status == .correct }.count

        let stats = TopicStatsStorage.shared.fetch(topicID: topic.id)
        self.attempts = stats.attempts
        self.sessionBestStreak = stats.bestStreak
        self.successfulCompletions = stats.successfulCompletions

        switch phase {
        case .notStarted:
            self.showPreview = false
            self.pendingQuestions = questions
            self.currentQuestion = questions[0]
            self.wrongInPool = []
            self.roundSize = questions.count
            self.visitedInRound = 0
        case .completed:
            self.showPreview = true
            self.pendingQuestions = []
            self.currentQuestion = questions[0]
            self.wrongInPool = []
            self.roundSize = 0
            self.visitedInRound = 0
        case .workingOnMistakes:
            let wrongs = questions.filter { wrongIDs.contains($0.id) }
            self.showPreview = true
            self.pendingQuestions = wrongs
            self.currentQuestion = wrongs[0]
            self.wrongInPool = wrongIDs
            // Берём прогресс круга из storage. Если его нет (старые данные) — стартуем новый.
            if stats.currentRoundSize > 0 {
                self.roundSize = stats.currentRoundSize
                self.visitedInRound = stats.visitedInRound
            } else {
                self.roundSize = wrongs.count
                self.visitedInRound = 0
            }
        case .inProgress:
            let unanswered = questions.filter { $0.status == .unanswered }
            let wrongs = questions.filter { $0.status == .wrong }
            let remaining = unanswered + wrongs
            self.showPreview = true
            self.pendingQuestions = remaining
            self.currentQuestion = remaining[0]
            self.wrongInPool = wrongIDs
            self.roundSize = questions.count
            // Берём из storage если есть; иначе считаем от количества посещённых.
            if stats.currentRoundSize == questions.count && stats.visitedInRound > 0 {
                self.visitedInRound = stats.visitedInRound
            } else {
                self.visitedInRound = (questions.count - unanswered.count)
            }
        }

        // Если в storage ещё ничего не записано — фиксируем стартовое состояние круга.
        if stats.currentRoundSize == 0 && self.roundSize > 0 {
            TopicStatsStorage.shared.setRoundProgress(
                topicID: topic.id,
                roundSize: self.roundSize,
                visited: self.visitedInRound
            )
        }
    }

    // MARK: - func

    func optionChanged(_ answer: Answer) {
        guard chosenAnswer != answer, !showSubView else { return }
        haptic.selectionChanged()
        chosenAnswer = answer
    }

    func buttonPressed() {
        showSubView ? next() : answer()
    }

    func continueTest() {
        showPreview = false
    }

    func restartTest() {
        repository.restartTopic(topicID)
        guard let fresh = repository.topic(byID: topicID) else { return }
        pendingQuestions = fresh.questions
        currentQuestion = fresh.questions[0]
        correctCount = 0
        questionStep = 0
        chosenAnswer = nil
        showSubView = false
        feedbackText = ""
        wrongInPool = []
        phase = .notStarted
        showPreview = false

        currentStreak = 0
        sessionBestStreak = 0
        attempts = 0

        roundSize = fresh.questions.count
        visitedInRound = 0

        statsStorage.resetAttemptStats(topicID: topicID)
        statsStorage.setRoundProgress(topicID: topicID, roundSize: roundSize, visited: visitedInRound)
    }

    func rowState(for answer: Answer) -> AnswerRowState {
        if !showSubView {
            return chosenAnswer == answer ? .selected : .idle
        }
        if answer.isCorrect && chosenAnswer == answer { return .correct }
        if answer.isCorrect { return .revealCorrect }
        if chosenAnswer == answer { return .wrong }
        return .idle
    }

    // MARK: - private func

    private func answer() {
        guard let chosen = chosenAnswer else { return }

        repository.recordAnswer(questionID: currentQuestion.id, isCorrect: chosen.isCorrect)

        // Best streak считается только в первом проходе (notStarted / inProgress).
        // В workingOnMistakes серия не накапливается.
        if phase == .notStarted || phase == .inProgress {
            if chosen.isCorrect {
                currentStreak += 1
                if currentStreak > sessionBestStreak {
                    sessionBestStreak = currentStreak
                    statsStorage.setBestStreak(topicID: topicID, value: sessionBestStreak)
                }
            } else {
                currentStreak = 0
            }
        }

        showSubView = true
        feedbackText = FeedbackPhrase.random(correct: chosen.isCorrect)
        haptic.notification(type: chosen.isCorrect ? .success : .error)
    }

    private func next() {
        guard let chosen = chosenAnswer else { return }

        if chosen.isCorrect {
            correctCount += 1
            wrongInPool.remove(currentQuestion.id)
            pendingQuestions.removeFirst()
        } else {
            wrongInPool.insert(currentQuestion.id)
            let q = pendingQuestions.removeFirst()
            pendingQuestions.append(q)
        }

        visitedInRound += 1
        persistRoundProgress()
        let phaseBefore = phase

        chosenAnswer = nil
        showSubView = false
        feedbackText = ""

        // Проверяем завершение текущего круга по массиву вопросов.
        if visitedInRound >= roundSize {
            if pendingQuestions.isEmpty {
                // Все ответы верные — тема пройдена.
                phase = .completed
                finishRound(completed: true)
                showPreview = true
                return
            }

            // Остались ошибки — круг закончен, начинается новый.
            finishRound(completed: false)
            startNewRound()

            if phaseBefore == .notStarted || phaseBefore == .inProgress {
                // Переход к работе над ошибками — показываем превью.
                phase = .workingOnMistakes
                currentQuestion = pendingQuestions[0]
                showPreview = true
                return
            }
            // В workingOnMistakes — тихий переход к следующему кругу, без превью.
        }

        guard !pendingQuestions.isEmpty else { return }
        questionStep += 1
        currentQuestion = pendingQuestions[0]
    }

    // Завершение «круга»: всегда инкрементируем attempts,
    // дополнительно — successfulCompletions если фаза стала .completed.
    private func finishRound(completed: Bool) {
        attempts = statsStorage.incrementAttempts(topicID: topicID)
        if completed {
            successfulCompletions = statsStorage.incrementSuccessfulCompletions(topicID: topicID)
        }
    }

    // Начинаем новый круг по текущему пулу вопросов.
    private func startNewRound() {
        roundSize = pendingQuestions.count
        visitedInRound = 0
        persistRoundProgress()
    }

    private func persistRoundProgress() {
        statsStorage.setRoundProgress(topicID: topicID, roundSize: roundSize, visited: visitedInRound)
    }
}
