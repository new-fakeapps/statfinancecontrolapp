import Foundation
import Combine

class FinanceStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var recurringTransactions: [RecurringTransaction] = []
    @Published var budgetGoals: BudgetGoals = BudgetGoals()
    
    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double {
        totalIncome - totalExpense
    }
    
    // MARK: - Monthly Income/Expense
    
    func monthlyIncome(for month: Date = Date()) -> Double {
        let calendar = Calendar.current
        return transactions.filter { 
            $0.type == .income && 
            calendar.isDate($0.date, equalTo: month, toGranularity: .month) &&
            calendar.isDate($0.date, equalTo: month, toGranularity: .year)
        }.reduce(0) { $0 + $1.amount }
    }
    
    func monthlyExpense(for month: Date = Date()) -> Double {
        let calendar = Calendar.current
        return transactions.filter { 
            $0.type == .expense && 
            calendar.isDate($0.date, equalTo: month, toGranularity: .month) &&
            calendar.isDate($0.date, equalTo: month, toGranularity: .year)
        }.reduce(0) { $0 + $1.amount }
    }
    
    func monthlyExpenseByCategory(category: Category, for month: Date = Date()) -> Double {
        let calendar = Calendar.current
        return transactions.filter { 
            $0.type == .expense && 
            $0.category == category &&
            calendar.isDate($0.date, equalTo: month, toGranularity: .month) &&
            calendar.isDate($0.date, equalTo: month, toGranularity: .year)
        }.reduce(0) { $0 + $1.amount }
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
    
    // MARK: - CRUD Operations for Regular Transactions
    
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
    
    // MARK: - Recurring Transactions
    
    func addRecurringTransaction(_ recurringTransaction: RecurringTransaction) {
        self.objectWillChange.send()
        recurringTransactions.append(recurringTransaction)
        saveRecurringTransactions()
        
        // Process it immediately if needed
        processRecurringTransaction(recurringTransaction)
        
        print("Added recurring transaction: \(recurringTransaction.type) - \(recurringTransaction.amount) rub - \(recurringTransaction.frequency.rawValue)")
    }
    
    func updateRecurringTransaction(_ transaction: RecurringTransaction) {
        if let index = recurringTransactions.firstIndex(where: { $0.id == transaction.id }) {
            recurringTransactions[index] = transaction
            saveRecurringTransactions()
        }
    }
    
    func deleteRecurringTransaction(_ id: UUID) {
        recurringTransactions.removeAll { $0.id == id }
        saveRecurringTransactions()
    }
    
    func processRecurringTransactions() {
        let currentDate = Date()
        
        for index in recurringTransactions.indices {
            let recurringTransaction = recurringTransactions[index]
            processRecurringTransaction(recurringTransaction)
        }
    }
    
    private func processRecurringTransaction(_ recurringTransaction: RecurringTransaction) {
        let currentDate = Date()
        
        if recurringTransaction.shouldCreateTransaction(asOf: currentDate) {
            // Create a regular transaction
            let transaction = recurringTransaction.createTransaction(date: currentDate)
            addTransaction(transaction)
            
            // Update the last processed date
            var updatedRecurringTransaction = recurringTransaction
            updatedRecurringTransaction.lastProcessedDate = currentDate
            
            // Update in the array
            if let index = recurringTransactions.firstIndex(where: { $0.id == recurringTransaction.id }) {
                recurringTransactions[index] = updatedRecurringTransaction
                saveRecurringTransactions()
            }
        }
    }
    
    // MARK: - Budget Goals
    
    func setMonthlyIncomeGoal(_ amount: Double?) {
        budgetGoals.monthlyIncomeGoal = amount
        saveBudgetGoals()
    }
    
    func setCategoryLimit(category: Category, amount: Double) {
        budgetGoals.setLimit(for: category, amount: amount)
        saveBudgetGoals()
    }
    
    func removeCategoryLimit(category: Category) {
        budgetGoals.removeLimit(for: category)
        saveBudgetGoals()
    }
    
    func isCategoryLimitExceeded(category: Category) -> Bool {
        let currentSpending = monthlyExpenseByCategory(category: category)
        return budgetGoals.isCategoryLimitExceeded(category: category, currentSpending: currentSpending)
    }
    
    func getMonthlyIncomeGoalProgress() -> Double {
        let currentIncome = monthlyIncome()
        return budgetGoals.incomeGoalProgress(currentIncome: currentIncome)
    }
    
    // MARK: - Persistence
    
    private let transactionsSaveKey = "FinanceTransactions"
    private let recurringTransactionsSaveKey = "RecurringTransactions"
    private let budgetGoalsSaveKey = "BudgetGoals"
    
    func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsSaveKey)
            UserDefaults.standard.synchronize()
            print("Saved \(transactions.count) transactions to UserDefaults")
        } else {
            print("Failed to encode transactions")
        }
    }
    
    func saveRecurringTransactions() {
        if let encoded = try? JSONEncoder().encode(recurringTransactions) {
            UserDefaults.standard.set(encoded, forKey: recurringTransactionsSaveKey)
            UserDefaults.standard.synchronize()
            print("Saved \(recurringTransactions.count) recurring transactions to UserDefaults")
        } else {
            print("Failed to encode recurring transactions")
        }
    }
    
    func saveBudgetGoals() {
        if let encoded = try? JSONEncoder().encode(budgetGoals) {
            UserDefaults.standard.set(encoded, forKey: budgetGoalsSaveKey)
            UserDefaults.standard.synchronize()
            print("Saved budget goals to UserDefaults")
        } else {
            print("Failed to encode budget goals")
        }
    }
    
    func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: transactionsSaveKey),
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
    
    func loadRecurringTransactions() {
        if let data = UserDefaults.standard.data(forKey: recurringTransactionsSaveKey),
           let decoded = try? JSONDecoder().decode([RecurringTransaction].self, from: data) {
            self.recurringTransactions = decoded
            print("Loaded \(recurringTransactions.count) recurring transactions from UserDefaults")
        } else {
            print("No saved recurring transactions found or failed to decode")
            recurringTransactions = []
        }
    }
    
    func loadBudgetGoals() {
        if let data = UserDefaults.standard.data(forKey: budgetGoalsSaveKey),
           let decoded = try? JSONDecoder().decode(BudgetGoals.self, from: data) {
            self.budgetGoals = decoded
            print("Loaded budget goals from UserDefaults")
        } else {
            print("No saved budget goals found or failed to decode")
            budgetGoals = BudgetGoals()
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
        loadRecurringTransactions()
        loadBudgetGoals()
        
        // Process recurring transactions on app start
        processRecurringTransactions()
        
        // Debug output
        print("FinanceStore initialized with \(transactions.count) transactions and \(recurringTransactions.count) recurring transactions")
        print("Current balance: \(balance)")
    }
}