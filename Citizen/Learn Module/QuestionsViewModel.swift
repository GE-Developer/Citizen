//
//  QuestionsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

final class QuestionsViewModel: ObservableObject {

    // MARK: - var

    @Published var chosenAnswer: Answer?

    var continueButtonDisabled: Bool { chosenAnswer == nil }
    var progress: Double { Double(correctCount) / Double(questionsCount) }
    var mistakesRemaining: Int { pendingQuestions.count }

    // MARK: - private(set) var

    @Published private(set) var currentQuestion: Question
    @Published private(set) var questionStep: Int = 0
    @Published private(set) var correctCount: Int
    @Published private(set) var showSubView = false
    @Published private(set) var showPreview: Bool
    @Published private(set) var subViewTitle = ""
    @Published private(set) var phase: TopicPhase

    // MARK: - let

    let topicTitle: String
    let questionsCount: Int
    let restartTitle = "Начать сначала"
    let restartSubtitle = "Прогресс будет сброшен"
    let exitTitle = "Выйти"

    // MARK: - private var

    @Published private var pendingQuestions: [Question]
    private var wrongInPool: Set<String>

    // MARK: - private let

    private let topicID: String
    private let haptic = HapticsManager.shared
    private let repository = QuizRepository.shared

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

        switch phase {
        case .notStarted:
            self.showPreview = false
            self.pendingQuestions = questions
            self.currentQuestion = questions[0]
            self.wrongInPool = []
        case .completed:
            self.showPreview = true
            self.pendingQuestions = []
            self.currentQuestion = questions[0]
            self.wrongInPool = []
        case .workingOnMistakes:
            let wrongs = questions.filter { wrongIDs.contains($0.id) }
            self.showPreview = true
            self.pendingQuestions = wrongs
            self.currentQuestion = wrongs[0]
            self.wrongInPool = wrongIDs
        case .inProgress:
            let unanswered = questions.filter { $0.status == .unanswered }
            let wrongs = questions.filter { $0.status == .wrong }
            let remaining = unanswered + wrongs
            self.showPreview = true
            self.pendingQuestions = remaining
            self.currentQuestion = remaining[0]
            self.wrongInPool = wrongIDs
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
        subViewTitle = ""
        wrongInPool = []
        phase = .notStarted
        showPreview = false
    }

    // MARK: - private func

    private func answer() {
        guard let chosen = chosenAnswer else { return }
        repository.recordAnswer(questionID: currentQuestion.id, isCorrect: chosen.isCorrect)
        showSubView = true
        subViewTitle = chosen.isCorrect ? "Правильно" : "Неправильно"
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

        chosenAnswer = nil
        showSubView = false
        subViewTitle = ""

        switch phase {
        case .notStarted, .inProgress:
            let visitedCount = correctCount + wrongInPool.count
            if visitedCount == questionsCount {
                if pendingQuestions.isEmpty {
                    phase = .completed
                } else {
                    currentQuestion = pendingQuestions[0]
                    phase = .workingOnMistakes
                }
                showPreview = true
                return
            }
        case .workingOnMistakes:
            if pendingQuestions.isEmpty {
                phase = .completed
                showPreview = true
                return
            }
        case .completed:
            break
        }

        guard !pendingQuestions.isEmpty else { return }
        questionStep += 1
        currentQuestion = pendingQuestions[0]
    }
}
