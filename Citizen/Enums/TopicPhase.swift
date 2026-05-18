//
//  TopicPhase.swift
//  Citizen
//
//  Created by GE-Developer
//

// Перечисление описывает все возможные состояния темы
enum TopicPhase {
    case notStarted        // тема ещё не открывалась
    case inProgress        // часть вопросов отвечена, тема не завершена
    case workingOnMistakes // все вопросы пройдены, но есть ошибки для разбора
    case completed         // тема полностью пройдена без ошибок в пуле

    // Заголовок для hero-секции превью-экрана; nil — превью не показывается
    var previewTitle: String? {
        switch self {
        case .notStarted:        nil
        case .inProgress:        "Продолжаем!"
        case .workingOnMistakes: "Работа над ошибками"
        case .completed:         "Тема пройдена!"
        }
    }

    // Текст основной кнопки действия на превью-экране; nil — кнопка не показывается
    var primaryActionTitle: String? {
        switch self {
        case .notStarted:        nil
        case .inProgress:        "Продолжить"
        case .workingOnMistakes: "Разобрать ошибки"
        case .completed:         "Пройти заново"
        }
    }

    // Текст плашки-статуса на карточке темы в списке топиков
    var pillTitle: String {
        switch self {
        case .notStarted:        "Начать"
        case .inProgress:        "В процессе"
        case .workingOnMistakes: "Ошибки"
        case .completed:         "Выполнено"
        }
    }
}
