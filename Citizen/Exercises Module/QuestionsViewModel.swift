//
//  QuestionsViewModel.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

final class QuestionsViewModel: ObservableObject {
    enum Phase {
        case restarted
        case continued
        case workingOnMistakes
    }
    
    
    private let allQuestions: [Question]
    @Published private var questions: [Question]
    
    let questionsCount: Int
    @Published private(set) var correctCount: Int
    
    @Published private(set) var currentQuestion: Question
    @Published var chosenOption: Option?
    @Published private(set) var showSubView = false
    @Published private(set) var showPreview: Bool
    @Published private(set) var subViewTitle = ""
    
    private var wrongIDs: Set<String>
    
    
    @Published private(set) var currentIndex: Int = 0


    @Published private(set) var phase: Phase? = nil
    
    var continueButtonDisabled: Bool { chosenOption == nil }
    var progress: Double { Double(correctCount) / Double(questionsCount) }
    
    
    private let haptic = HapticsManager.shared
    private let answerStorage: AnswerStorage
    
    var startViewTitle: String {
        switch phase {
        case .restarted: "Начать сначала"
        case .continued: "Продолжить?"
        case .workingOnMistakes: "Работа над ошибками"
        case nil: ""
        }
    }
    
    private(set) var startViewDescription = ""
    
    init(_ questions: [Question]) {
        self.answerStorage = AnswerStorage.shared
        self.allQuestions = questions
        self.questionsCount = questions.count
        
        let fetchedCorrectIDs = answerStorage.fetchCorrectIDs()
        let fetchedWrongIDs = answerStorage.fetchWrongIDs()
        let allFetchedIDs = fetchedCorrectIDs + fetchedWrongIDs
        
        if allFetchedIDs.isEmpty {
            self.showPreview = false
            self.questions = questions
            self.currentQuestion = questions[0]
            self.correctCount = 0
            self.wrongIDs = []
            print("Начато с нуля")
        } else if fetchedCorrectIDs.count == questions.count {
            self.phase = .restarted
            self.showPreview = true
//            AnswerStorage.shared.reset()
            self.questions = questions
            self.currentQuestion = questions[0]
            self.correctCount = 0
            self.wrongIDs = []
            print("Начато сначала после прохождения")
        } else if allFetchedIDs.count == questions.count {
            let wrongs = questions.filter { fetchedWrongIDs.contains($0.id) }
            self.phase = .workingOnMistakes
            self.showPreview = true
            self.questions = wrongs
            self.currentQuestion = wrongs[0]
            self.correctCount = questions.count - wrongs.count
            self.wrongIDs = []
            print("Началась работа над ошибками")
        } else {
            let unAnswered = questions.filter { !allFetchedIDs.contains($0.id) }
            let wrongs = questions.filter { fetchedWrongIDs.contains($0.id) }
            let remainQuestions = unAnswered + wrongs
            self.phase = .continued
            self.showPreview = true
            self.questions = remainQuestions
            self.currentQuestion = remainQuestions[0]
            self.correctCount = questions.count - remainQuestions.count
            self.wrongIDs = Set(wrongs.map { $0.id })
            print("Продолжаем после частичного прохождения")
        }
    }
    
    func optionChanged(_ option: Option) {
        guard chosenOption != option else { return }
        guard !showSubView else { return }
        haptic.selectionChanged()
        chosenOption = option
    }
    
    func buttonPressed() {
        showSubView ? next() : answer()
    }
    

    private func answer() {
        guard let option = chosenOption else { return }
        
        AnswerStorage.shared.saveAnswer(
            questionID: currentQuestion.id,
            isCorrect: option.isCorrect
        )
        
        showSubView = true
        
        if option.isCorrect {
            haptic.notification(type: .success)
            subViewTitle = "Правильно"
        } else {
            haptic.notification(type: .error)
            subViewTitle = "Одна ошибка и ты ошибся"
        }
        
        
    }
    
    
    
    private func next() {
        guard let option = chosenOption else { return }
        if option.isCorrect {
            correctCount = min(correctCount + 1, questionsCount)
            wrongIDs.remove(currentQuestion.id)
        } else {
//            wrongQuestions.append(currentQuestion)
            questions.append(currentQuestion)
            wrongIDs.insert(currentQuestion.id)
        }
        
        chosenOption = nil
        showSubView = false
        subViewTitle = ""
        
        
        guard progress < 1 else {
//            isFinished = true
            return
        }

        currentIndex += 1
        currentQuestion = questions[min(currentIndex, questions.count - 1)]
        
        guard phase != .workingOnMistakes else { return }
        if correctCount + wrongIDs.count == questionsCount {
            phase = .workingOnMistakes
            showPreview = true
            print("Работа над ошибками")
        }
    }
    
    func continueTest() {
        showPreview = false
        // ничего больше не делаем — уже стоим на remaining
    }
    
    func restartTest() {
        AnswerStorage.shared.reset() // очищаем CoreData
        showPreview = false

        // стартуем тест с самого начала
        self.questions = allQuestions
        self.currentQuestion = allQuestions[0]
        self.correctCount = 0
    }

}
