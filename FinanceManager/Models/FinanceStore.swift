import Foundation
import Combine

class FinanceStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpense
    }
    
    // MARK: - Filtering
    
    func filteredTransactions(type: TransactionType? = nil) -> [Transaction] {
        if let type = type {
            return transactions.filter { $0.type == type }
        } else {
            return transactions
        }
    }
    
    // MARK: - Recent Transactions
    
    var recentTransactions: [Transaction] {
        return transactions.sorted(by: { $0.date > $1.date }).prefix(10).map { $0 }
    }
    
    // MARK: - CRUD Operations
    
    func addTransaction(_ transaction: Transaction) {
        self.objectWillChange.send()
        transactions.append(transaction)
        saveTransactions()
        
        // Debug log
        print("Added transaction: \(transaction.type) - \(transaction.amount) rub")
        print("Total transactions: \(transactions.count)")
        
        // Force UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        saveTransactions()
    }
    
    // MARK: - Persistence
    
    private let saveKey = "FinanceTransactions"
    
    func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            UserDefaults.standard.synchronize() // Гарантируем сохранение данных
            print("Saved \(transactions.count) transactions to UserDefaults")
        } else {
            print("Failed to encode transactions")
        }
    }
    
    func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            self.transactions = decoded
            print("Loaded \(transactions.count) transactions from UserDefaults")
            
            // Force UI update
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } else {
            print("No saved transactions found or failed to decode")
            transactions = []
        }
    }
    
    // MARK: - Stats by Category
    
    func expensesByCategory() -> [Category: Double] {
        var result: [Category: Double] = [:]
        
        for category in Category.allCases {
            result[category] = 0
        }
        
        for transaction in transactions where transaction.type == .expense {
            if let category = transaction.category {
                result[category, default: 0] += transaction.amount
            }
        }
        
        return result
    }
    
    // MARK: - Initialization
    
    init() {
        loadTransactions()
        
        // Debug output
        print("FinanceStore initialized with \(transactions.count) transactions")
        print("Current balance: \(balance)")
    }
}