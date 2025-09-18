import Foundation

enum CategoryType: String, Codable, CaseIterable {
    case income = "Доход"
    case expense = "Расход"
}

enum RepeatRule: String, Codable, CaseIterable {
    case none = "Без повтора"
    case weekly = "Каждую неделю"
    case monthly = "Каждый месяц"
}

enum PeriodFilter: String, CaseIterable {
    case all = "Все"
    case week = "Неделя"
    case month = "Месяц"
}
