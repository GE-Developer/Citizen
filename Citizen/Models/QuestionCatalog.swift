//
//  QuestionCatalog.swift
//  Citizen
//
//  Created by GE-Developer
//
//  Иерархия моделей:
//  QuestionCatalog → [Category] → [Topic] → [Question] → [Answer]
//
//  Статические поля (id, name, текст и т.д.) приходят из JSON через Codable.
//  Пользовательское состояние (status, isInMistakePool) живёт ТОЛЬКО на Question.
//  Topic/Category/QuestionCatalog не хранят его сами — они выводят все агрегаты
//  через computed-properties, проходя по вложенным questions.
//
//  Почему categories/topics/questions объявлены как `var`:
//  это value-типы (struct), и QuizRepository обновляет состояние вопроса
//  цепочкой index-мутаций:
//      catalog.categories[ci].topics[ti].questions[qi].status = .correct
//  Чтобы такая цепочка компилировалась, каждое промежуточное звено должно
//  быть mutable. Снаружи каталог отдаётся через `private(set) var` в репозитории,
//  поэтому мутировать его можно только из репозитория — UI читает значения,
//  а @Observable сам публикует изменения.
//

// Статус ответа пользователя на конкретный вопрос.
// .unanswered — пользователь ещё не отвечал; .correct/.wrong — последний ответ.
// Перезаписывается при повторном прохождении.
enum AnswerStatus: Codable, Hashable {
    case unanswered
    case correct
    case wrong
}

struct QuestionCatalog: Codable, Hashable {
    var categories: [Category]

    // ── Глобальные агрегаты для главного экрана ──────────────────────────────
    // reduce(0) { $0 + $1.X } = «пройди по массиву слева направо, начиная с 0,
    // и каждое значение прибавляй к аккумулятору». То есть это просто сумма
    // X по всем категориям. Эквивалент цикла:
    //     var acc = 0
    //     for category in categories { acc += category.X }
    //     return acc

    // Сколько всего топиков во всех категориях.
    var totalTopics: Int { categories.reduce(0) { $0 + $1.totalTopics } }

    // Сколько топиков полностью пройдено без ошибок (phase == .completed).
    var completedTopics: Int { categories.reduce(0) { $0 + $1.completedTopics } }

    // Сколько всего вопросов в каталоге.
    var totalQuestions: Int { categories.reduce(0) { $0 + $1.totalQuestions } }

    // Сколько вопросов отвечено правильно (последний ответ был верным).
    var correctCount: Int { categories.reduce(0) { $0 + $1.correctCount } }

    // Сколько вопросов отвечено неправильно (текущее состояние, не история).
    var wrongCount: Int { categories.reduce(0) { $0 + $1.wrongCount } }

    // Общая «готовность к экзамену» от 0.0 до 1.0.
    var progress: Double { Double(correctCount) / Double(max(totalQuestions, 1)) }

    // ── Глобальный пул ошибок ────────────────────────────────────────────────
    // Источник — GlobalMistakeEntity (CoreData). Каждый Question, который хоть
    // раз был отвечён неправильно, помечается isInMistakePool = true.
    // Пул sticky: остаётся даже после исправления; очищается только явным
    // сбросом через AnswerStorage.
    //
    // flatMap «разворачивает» вложенные массивы:
    //     categories → all topics → all questions → отфильтрованные.

    // Сами вопросы из пула — отсортированы по порядку появления в каталоге
    // (category.index → topic.index → question.index, который и так в массиве).
    // Используется для экрана «Работа над глобальными ошибками».
    var mistakePoolQuestions: [Question] {
        categories.flatMap(\.topics).flatMap(\.questions).filter(\.isInMistakePool)
    }

    // Только ID вопросов из пула — лёгкая выборка, когда сами Question не нужны.
    var mistakePoolIDs: [String] {
        mistakePoolQuestions.map(\.id)
    }

    // Счётчик для кнопки «Review N mistakes» на главном экране.
    var mistakePoolCount: Int {
        mistakePoolQuestions.count
    }
}

struct Category: Codable, Hashable, Identifiable {
    let id: String
    let index: Int
    let name: String
    var topics: [Topic]

    // Сколько топиков в категории.
    var totalTopics: Int { topics.count }

    // Сумма totalCount по всем топикам категории.
    var totalQuestions: Int { topics.reduce(0) { $0 + $1.totalCount } }

    // Сумма правильных ответов по всем топикам категории.
    var correctCount: Int { topics.reduce(0) { $0 + $1.correctCount } }

    // Сумма текущих неправильных ответов по всем топикам категории.
    var wrongCount: Int { topics.reduce(0) { $0 + $1.wrongCount } }

    // Топики, у которых phase == .completed (все вопросы пройдены без ошибок).
    // lazy.filter не строит промежуточный массив — сразу считает count.
    var completedTopics: Int { topics.lazy.filter { $0.phase == .completed }.count }

    // Прогресс категории от 0.0 до 1.0.
    var progress: Double { Double(correctCount) / Double(max(totalQuestions, 1)) }
}

struct Topic: Codable, Hashable, Identifiable {
    let id: String
    let index: Int
    let name: String
    var questions: [Question]

    // Сколько вопросов в топике.
    var totalCount: Int { questions.count }

    // Сколько отвечено правильно. lazy.filter — без построения промежуточного массива.
    var correctCount: Int { questions.lazy.filter { $0.status == .correct }.count }

    // Сколько отвечено неправильно (текущее состояние).
    var wrongCount: Int { questions.lazy.filter { $0.status == .wrong }.count }

    // Сколько всего отвечено (включая ошибочные).
    var answeredCount: Int { correctCount + wrongCount }

    // Прогресс топика 0.0…1.0. max(_, 1) защищает от деления на ноль.
    var progress: Double { Double(correctCount) / Double(max(totalCount, 1)) }

    // Фаза топика — машина состояний, по которой строится UI карточки и логика
    // прохождения. Считается from-scratch на основе текущих status у вопросов.
    var phase: TopicPhase {
        guard totalCount > 0 else { return .notStarted }
        if answeredCount == 0 { return .notStarted }                     // ни одного ответа
        if answeredCount == totalCount && wrongCount == 0 { return .completed }   // все верно
        if answeredCount == totalCount { return .workingOnMistakes }     // все отвечены, есть ошибки
        return .inProgress                                               // часть отвечена
    }
}

struct Question: Codable, Hashable, Identifiable {
    // ── Статические поля из JSON ─────────────────────────────────────────────
    let id: String              // уникальный, например "geo-grammar-noun-I.1.1"
    let number: String          // отображаемая нумерация, например "I.1.1"
    let index: Int
    let question: String
    let additionalText: String
    let answers: [Answer]

    // ── Пользовательское состояние (НЕ декодируется из JSON) ────────────────
    // status — текущий ответ пользователя на этот вопрос.
    // Заполняется QuizRepository.hydrate() из QuestionEntity (CoreData).
    var status: AnswerStatus = .unanswered

    // isInMistakePool — флаг «вопрос когда-либо был отвечён неправильно».
    // Заполняется QuizRepository.hydrate() из GlobalMistakeEntity (CoreData).
    // Глобальный пул ошибок — это множество всех Question с isInMistakePool == true.
    // Флаг sticky: при исправлении ответа status станет .correct, но
    // isInMistakePool останется true — для секции «Review N mistakes».
    var isInMistakePool: Bool = false

    // CodingKeys без status / isInMistakePool — JSONDecoder их игнорирует,
    // и они получают значения по умолчанию (.unanswered / false).
    enum CodingKeys: String, CodingKey {
        case id, number, index, question, additionalText, answers
    }
}

struct Answer: Codable, Hashable, Identifiable {
    let text: String
    let isCorrect: Bool

    // Identifiable требует id — у Answer нет своего id в JSON, используем text.
    var id: String { text }
}
