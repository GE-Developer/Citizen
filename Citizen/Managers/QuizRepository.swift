//
//  QuizRepository.swift
//  Citizen
//
//  Created by GE-Developer
//
//  Единый источник правды для каталога вопросов и пользовательского прогресса.
//
//  Что делает:
//  1) При запуске декодирует questions.ge.json (база) и при необходимости
//     накладывает локализованные имена категорий/топиков из en/ru-overlay.
//  2) Гидратирует каталог — берёт сохранённые ответы и пул ошибок из CoreData
//     и проставляет каждому Question его status и isInMistakePool.
//  3) Принимает изменения от ViewModels: recordAnswer (после ответа на вопрос)
//     и restartTopic (после нажатия «Начать сначала»).
//
//  Почему @Observable: SwiftUI отслеживает чтение свойства catalog в любых
//  views/VM и автоматически перерисовывает их при мутации каталога.
//  Все UI-экраны читают репозиторий через computed-property и обновляются
//  без onAppear-перезагрузок.
//

import Foundation

@Observable
final class QuizRepository {
    // private(set) — мутировать каталог можно только изнутри репозитория.
    // Извне (VM, views) каталог только читается.
    private(set) var catalog: QuestionCatalog = QuestionCatalog(categories: [])

    static let shared = QuizRepository()

    private let storage = AnswerStorage.shared

    private init() {
        reload()
    }

    // MARK: - Public API

    // Полностью перезагружает каталог: JSON → overlay → гидратация из CoreData.
    // Вызывается при старте и при смене языка (LanguageManager).
    func reload() {
        guard let base = decode(langCode: "ge") else {
            catalog = QuestionCatalog(categories: [])
            return
        }
        let langCode = languageCode()
        // Для грузинского база — это и есть исходник; иначе пытаемся наложить
        // имена категорий/топиков из overlay (en/ru), но сам текст вопросов
        // остаётся на грузинском (это тест на знание языка).
        let merged = (langCode == "ge")
            ? base
            : decode(langCode: langCode).map { applyNameOverlay(base: base, overlay: $0) } ?? base
        catalog = hydrate(merged)
    }

    // Записывает ответ пользователя. Вызывается из QuestionsViewModel.answer().
    // Что происходит:
    // 1) В CoreData (QuestionEntity) сохраняется текущий результат (правильно/нет).
    // 2) Если ответ неправильный — questionID добавляется в GlobalMistakeEntity
    //    (это пополнение «глобального пула ошибок» для секции Review).
    // 3) Конкретный Question в каталоге обновляется in-place — @Observable
    //    публикует изменение, и UI (главный экран, список топиков) перерисуется.
    func recordAnswer(questionID: String, isCorrect: Bool) {
        storage.saveAnswer(questionID: questionID, isCorrect: isCorrect)
        if !isCorrect { storage.addToGlobalPool(questionID: questionID) }
        applyAnswerState(forQuestionID: questionID)
    }

    // Сброс топика. Вызывается из QuestionsViewModel.restartTest().
    // Удаляет из CoreData (QuestionEntity) все ответы по вопросам этого топика
    // и сбрасывает их status в .unanswered.
    // ВАЖНО: isInMistakePool НЕ сбрасывается — пул ошибок (GlobalMistakeEntity)
    // sticky, вопрос остаётся в пуле, даже если пользователь сбросил топик.
    func restartTopic(_ topicID: String) {
        guard let (ci, ti) = locate(topicID: topicID) else { return }
        let ids = catalog.categories[ci].topics[ti].questions.map(\.id)
        storage.removeAnswers(ids: ids)
        for qi in catalog.categories[ci].topics[ti].questions.indices {
            catalog.categories[ci].topics[ti].questions[qi].status = .unanswered
        }
    }

    // Удобный аксессор — найти Topic по id, обходя категории.
    // Используется QuestionsViewModel, чтобы получить «свежий» Topic из каталога
    // (внутри Topic value-копия, и если хранить её, она устаревает после мутации).
    func topic(byID id: String) -> Topic? {
        catalog.categories.lazy.flatMap(\.topics).first { $0.id == id }
    }

    // MARK: - Private helpers

    // Маппинг ID языка из LanguageManager на префикс json-файла.
    private func languageCode() -> String {
        switch LanguageManager.shared.currentLanguageID {
        case "ka": return "ge"
        case "en": return "en"
        case "ru": return "ru"
        default: return "ge"
        }
    }

    // Накладывает имена категорий и топиков из overlay-каталога на базу.
    // Вопросы и ответы НЕ заменяются — они всегда грузинские.
    // uniquingKeysWith: { first, _ in first } — если в JSON встретятся дубли id
    // у категорий/топиков, берём первое значение и не падаем.
    private func applyNameOverlay(base: QuestionCatalog, overlay: QuestionCatalog) -> QuestionCatalog {
        let overlayMap = Dictionary(overlay.categories.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let merged = base.categories.map { baseCategory -> Category in
            guard let overlayCategory = overlayMap[baseCategory.id] else { return baseCategory }
            let topicOverlayMap = Dictionary(overlayCategory.topics.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            let mergedTopics = baseCategory.topics.map { baseTopic -> Topic in
                guard let overlayTopic = topicOverlayMap[baseTopic.id] else { return baseTopic }
                return Topic(id: baseTopic.id, index: baseTopic.index, name: overlayTopic.name, questions: baseTopic.questions)
            }
            return Category(id: baseCategory.id, index: baseCategory.index, name: overlayCategory.name, topics: mergedTopics)
        }
        return QuestionCatalog(categories: merged)
    }

    // Сам парсинг JSON: ищет файл в bundle, декодирует в QuestionCatalog.
    private func decode(langCode: String) -> QuestionCatalog? {
        let name = "questions.\(langCode)"
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(QuestionCatalog.self, from: data)
        } catch {
            print("[QuizRepository] decode error for \(name).json: \(error)")
            return nil
        }
    }

    // Гидратация = «налить» пользовательское состояние в декодированный каталог.
    // Вызывается один раз при reload(). Идёт по всем вопросам и проставляет:
    //   • status — из QuestionEntity (id, isCorrect) → .correct/.wrong, либо .unanswered
    //   • isInMistakePool — из GlobalMistakeEntity (хранит ID вопросов с ошибками)
    private func hydrate(_ catalog: QuestionCatalog) -> QuestionCatalog {
        let answered = storage.fetchAllAnswered()             // [questionID: Bool]
        let pool = Set(storage.fetchGlobalWrongIDs())          // глобальный пул ошибок
        var hydrated = catalog
        for ci in hydrated.categories.indices {
            for ti in hydrated.categories[ci].topics.indices {
                for qi in hydrated.categories[ci].topics[ti].questions.indices {
                    let qid = hydrated.categories[ci].topics[ti].questions[qi].id
                    hydrated.categories[ci].topics[ti].questions[qi].status =
                        answered[qid].map { $0 ? .correct : .wrong } ?? .unanswered
                    hydrated.categories[ci].topics[ti].questions[qi].isInMistakePool = pool.contains(qid)
                }
            }
        }
        return hydrated
    }

    // Точечное обновление одного вопроса в каталоге после recordAnswer.
    // Не перестраивает каталог целиком — только меняет два поля в нужном
    // Question по index path. @Observable отслеживает мутацию и публикует её.
    private func applyAnswerState(forQuestionID id: String) {
        guard let (ci, ti, qi) = locate(questionID: id) else { return }
        let answered = storage.fetchAllAnswered()
        let pool = Set(storage.fetchGlobalWrongIDs())
        catalog.categories[ci].topics[ti].questions[qi].status =
            answered[id].map { $0 ? .correct : .wrong } ?? .unanswered
        catalog.categories[ci].topics[ti].questions[qi].isInMistakePool = pool.contains(id)
    }

    // Поиск индексов категории+топика по topicID. Возвращает (ci, ti) для
    // последующей index-мутации каталога.
    private func locate(topicID: String) -> (Int, Int)? {
        for ci in catalog.categories.indices {
            for ti in catalog.categories[ci].topics.indices {
                if catalog.categories[ci].topics[ti].id == topicID {
                    return (ci, ti)
                }
            }
        }
        return nil
    }

    // Поиск индексов категории+топика+вопроса по questionID.
    private func locate(questionID: String) -> (Int, Int, Int)? {
        for ci in catalog.categories.indices {
            for ti in catalog.categories[ci].topics.indices {
                if let qi = catalog.categories[ci].topics[ti].questions.firstIndex(where: { $0.id == questionID }) {
                    return (ci, ti, qi)
                }
            }
        }
        return nil
    }
}
