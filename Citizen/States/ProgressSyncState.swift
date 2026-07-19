//
//  ProgressSyncState.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation

// Это "память" синхронизации прогресса — здесь хранится ВСЁ, что нужно
// помнить между запусками приложения, чтобы понимать: есть ли несохранённые
// изменения, чей это прогресс, и что мы в последний раз видели на сервере.
// Все значения дублируются в UserDefaults (на диске), чтобы не потерять их
// при перезапуске приложения.
/// Persistent sync bookkeeping. Dirty is a pair of monotonic counters, not a bool:
/// a push captures `localChangeCount` before its network await and advances
/// `syncedChangeCount` only to the captured value — writes that land during the
/// upload keep the store dirty and trigger a follow-up push.
@MainActor
final class ProgressSyncState {
    // "Есть ли несохранённые (незалитые на сервер) изменения?" Хитрость в том,
    // что это НЕ отдельный флажок true/false, а сравнение двух счётчиков —
    // почему так объяснено ниже, у самих счётчиков.
    var isDirty: Bool {
        localChangeCount != syncedChangeCount
    }

    // Счётчик "сколько раз что-то изменилось локально" — растёт на +1 при
    // каждом ответе на вопрос, сохранении слова и т.д.
    private(set) var localChangeCount: Int
    // Счётчик "до какого значения localChangeCount мы УЖЕ успешно отправили
    // на сервер". Если оба счётчика равны — значит, всё отправлено, изменений
    // не осталось. Почему два счётчика, а не просто bool "изменилось/нет":
    // пока идёт отправка на сервер (это не мгновенно), пользователь может
    // успеть ответить ещё на несколько вопросов — эти новые изменения не
    // должны потеряться, а должны дождаться СЛЕДУЮЩЕЙ отправки.
    private(set) var syncedChangeCount: Int
    // Когда именно последний раз что-то поменялось локально — нужно только
    // для редкого случая конфликта (см. ниже в ProgressSync.swift).
    private(set) var lastLocalChangeAt: Date?
    /// Opaque server-issued `updated_at` string — compared by equality only, never parsed.
    // Последняя известная нам "метка времени" с сервера. Это просто текст,
    // мы её не расшифровываем — только сравниваем "такая же или другая".
    private(set) var lastSyncedServerUpdatedAt: String?
    // ID пользователя, чей прогресс сейчас хранится на этом устройстве.
    private(set) var lastSyncedUserID: String?

    static let shared = ProgressSyncState() // единственный экземпляр на всё приложение

    private let defaults = UserDefaults.standard // хранилище настроек на диске телефона

    // При создании класса читаем всё, что было сохранено с прошлого запуска.
    private init() {
        localChangeCount = defaults.integer(forKey: AppStorageKey.syncLocalChangeCount.key)
        syncedChangeCount = defaults.integer(forKey: AppStorageKey.syncSyncedChangeCount.key)
        let changedAt = defaults.double(forKey: AppStorageKey.syncLastLocalChangeAt.key)
        // UserDefaults не умеет хранить Date напрямую, поэтому хранится число
        // секунд с 1970 года — здесь превращаем это число обратно в Date.
        // 0 (то есть "ключа никогда не было") — значит, изменений ещё не было.
        lastLocalChangeAt = changedAt > 0 ? Date(timeIntervalSince1970: changedAt) : nil
        lastSyncedServerUpdatedAt = defaults.string(forKey: AppStorageKey.syncServerUpdatedAt.key)
        lastSyncedUserID = defaults.string(forKey: AppStorageKey.syncLastUserID.key)
    }

    // Вызывается КАЖДЫЙ раз, когда пользователь что-то поменял в прогрессе
    // (ответил на вопрос, сохранил слово и т.п.) — увеличивает счётчик и
    // тут же сохраняет его на диск, чтобы не потерять при внезапном закрытии.
    func noteLocalChange() {
        localChangeCount += 1
        lastLocalChangeAt = Date()
        defaults.set(localChangeCount, forKey: AppStorageKey.syncLocalChangeCount.key)
        defaults.set(
            lastLocalChangeAt?.timeIntervalSince1970 ?? 0,
            forKey: AppStorageKey.syncLastLocalChangeAt.key
        )
    }

    // Вызывается ПОСЛЕ успешной отправки прогресса на сервер: запоминаем, до
    // какого счётчика мы дошли, какую метку времени вернул сервер, и для
    // какого именно пользователя всё это было.
    func markSynced(changeCount: Int, serverUpdatedAt: String, userID: UUID) {
        syncedChangeCount = changeCount
        lastSyncedServerUpdatedAt = serverUpdatedAt
        lastSyncedUserID = userID.uuidString
        defaults.set(syncedChangeCount, forKey: AppStorageKey.syncSyncedChangeCount.key)
        defaults.set(serverUpdatedAt, forKey: AppStorageKey.syncServerUpdatedAt.key)
        defaults.set(lastSyncedUserID, forKey: AppStorageKey.syncLastUserID.key)
    }

    /// First pass ever on this install (`lastSyncedUserID` is nil): record who owns the
    /// local data WITHOUT touching counters or the dirty state. Without the claim, a first
    /// user who never managed a successful push (offline) would leave the ID nil, and the
    /// account-switch wipe could not tell the next user's sign-in from a same-user relaunch.
    // "Застолбить" — записать, чей прогресс лежит на этом устройстве, НЕ трогая
    // при этом счётчики. Нужно для случая: человек только что зарегистрировался,
    // ответил на вопросы БЕЗ интернета (отправить на сервер не получилось —
    // lastSyncedUserID так и остался пустым), потом вышел и зашёл под ДРУГИМ
    // аккаунтом. Без этого "застолбления" приложение не поняло бы, что
    // локальный прогресс принадлежит первому человеку, и могло бы случайно
    // залить его на аккаунт второго.
    func claimUser(_ userID: UUID) {
        lastSyncedUserID = userID.uuidString
        defaults.set(lastSyncedUserID, forKey: AppStorageKey.syncLastUserID.key)
    }

    /// Server row disappeared while local is empty too — forget the stale token
    /// so the next comparison treats the account as never-synced.
    // Забыть последнюю известную метку сервера — используется, когда на
    // сервере строка с прогрессом пропала, а локально и так пусто: нет смысла
    // хранить устаревшую метку, лучше считать, что синхронизации ещё не было.
    func clearServerToken() {
        lastSyncedServerUpdatedAt = nil
        defaults.removeObject(forKey: AppStorageKey.syncServerUpdatedAt.key)
    }

    /// Account deleted: forget everything, including `lastSyncedUserID`, so a subsequent
    /// fresh account starts from a clean slate and never re-uploads the deleted user's data.
    // Полностью забыть ВСЁ — используется при удалении аккаунта, чтобы если
    // потом кто-то (даже тот же человек) заведёт новый аккаунт, старые данные
    // случайно не "воскресли" и не залились на новый аккаунт.
    func clearAll() {
        localChangeCount = 0
        syncedChangeCount = 0
        lastLocalChangeAt = nil
        lastSyncedServerUpdatedAt = nil
        lastSyncedUserID = nil
        defaults.removeObject(forKey: AppStorageKey.syncLocalChangeCount.key)
        defaults.removeObject(forKey: AppStorageKey.syncSyncedChangeCount.key)
        defaults.removeObject(forKey: AppStorageKey.syncLastLocalChangeAt.key)
        defaults.removeObject(forKey: AppStorageKey.syncServerUpdatedAt.key)
        defaults.removeObject(forKey: AppStorageKey.syncLastUserID.key)
    }

    // Сброс "на чистый лист" под конкретного НОВОГО пользователя — используется
    // при входе в другой аккаунт на этом же устройстве: счётчики обнуляем
    // (локальный прогресс уже стёрт в другом месте кода), но сразу же
    // записываем, что теперь устройство принадлежит именно этому userID.
    func resetForAccountSwitch(to userID: UUID) {
        localChangeCount = 0
        syncedChangeCount = 0
        lastLocalChangeAt = nil
        lastSyncedServerUpdatedAt = nil
        lastSyncedUserID = userID.uuidString
        defaults.set(0, forKey: AppStorageKey.syncLocalChangeCount.key)
        defaults.set(0, forKey: AppStorageKey.syncSyncedChangeCount.key)
        defaults.removeObject(forKey: AppStorageKey.syncLastLocalChangeAt.key)
        defaults.removeObject(forKey: AppStorageKey.syncServerUpdatedAt.key)
        defaults.set(lastSyncedUserID, forKey: AppStorageKey.syncLastUserID.key)
    }
}
