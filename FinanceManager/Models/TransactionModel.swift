import Foundation

enum TransactionType: Codable {
    case income, expense
}

enum Category: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    case food = "Продукты"
    case transport = "Транспорт"
    case entertainment = "Развлечения"
    case utilities = "Коммунальные"
    case health = "Здоровье"
    case home = "Дом"
    case education = "Образование"
    case clothing = "Одежда"
    case travel = "Путешествия"
    case pets = "Домашние животные"
    case other = "Другое"
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    let type: TransactionType
    let amount: Double
    let category: Category? // Only for expense
    let note: String
    let date: Date
    
    init(id: UUID = UUID(), type: TransactionType, amount: Double, category: Category? = nil, note: String = "", date: Date = Date()) {
        self.id = id
        self.type = type
        self.amount = amount
        self.category = type == .expense ? category : nil // Ensure category is nil for income
        self.note = note
        self.date = date
    }
}