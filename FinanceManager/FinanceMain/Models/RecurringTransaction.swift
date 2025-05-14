import Foundation

enum RecurrenceFrequency: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    case daily = "Каждый день"
    case weekly = "Раз в неделю"
    case monthly = "Ежемесячно"
}

struct RecurringTransaction: Identifiable, Codable {
    let id: UUID
    let type: TransactionType
    let amount: Double
    let category: Category?
    let note: String
    let frequency: RecurrenceFrequency
    let startDate: Date
    var lastProcessedDate: Date?
    
    init(id: UUID = UUID(), 
         type: TransactionType, 
         amount: Double, 
         category: Category? = nil, 
         note: String = "", 
         frequency: RecurrenceFrequency, 
         startDate: Date = Date(),
         lastProcessedDate: Date? = nil) {
        self.id = id
        self.type = type
        self.amount = amount
        self.category = type == .expense ? category : nil
        self.note = note
        self.frequency = frequency
        self.startDate = startDate
        self.lastProcessedDate = lastProcessedDate
    }
    
    /// Checks if a new transaction should be created based on the recurrence pattern
    func shouldCreateTransaction(asOf currentDate: Date = Date()) -> Bool {
        guard let lastProcessed = lastProcessedDate else {
            // If never processed, create transaction if start date has passed
            return startDate <= currentDate
        }
        
        let calendar = Calendar.current
        
        switch frequency {
        case .daily:
            // Check if a day has passed since last processing
            return !calendar.isDate(lastProcessed, inSameDayAs: currentDate)
            
        case .weekly:
            // Check if a week has passed since last processing
            guard let nextWeekDate = calendar.date(byAdding: .weekOfYear, value: 1, to: lastProcessed) else {
                return false
            }
            return currentDate >= nextWeekDate
            
        case .monthly:
            // Check if a month has passed since last processing
            guard let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: lastProcessed) else {
                return false
            }
            return currentDate >= nextMonthDate
        }
    }
    
    /// Creates a regular transaction from this recurring transaction
    func createTransaction(date: Date = Date()) -> Transaction {
        return Transaction(
            type: type,
            amount: amount,
            category: category,
            note: note,
            date: date
        )
    }
} 