import SwiftUI

struct RecurringTransactionsView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var showingAddSheet = false
    @State private var transactionToEdit: RecurringTransaction? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                VStack {
                    if financeStore.recurringTransactions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "repeat.circle")
                                .font(.system(size: 60))
                                .foregroundColor(ThemeColors.accent)
                            
                            Text("Нет повторяющихся платежей")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryText)
                            
                            Text("Добавьте повторяющиеся доходы или расходы, чтобы они автоматически создавались в указанный период")
                                .multilineTextAlignment(.center)
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.secondaryText)
                                .padding(.horizontal)
                            
                            Button(action: {
                                showingAddSheet = true
                            }) {
                                Text("Добавить")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(ThemeColors.accent)
                                    .cornerRadius(10)
                            }
                            .padding(.top)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(financeStore.recurringTransactions) { recurringTransaction in
                                    RecurringTransactionRow(transaction: recurringTransaction)
                                        .onTapGesture {
                                            transactionToEdit = recurringTransaction
                                        }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Повторяющиеся")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !financeStore.recurringTransactions.isEmpty {
                        Button(action: {
                            showingAddSheet = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(ThemeColors.primaryText)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                RecurringTransactionFormView(isPresented: $showingAddSheet)
            }
            .sheet(item: $transactionToEdit) { transaction in
                RecurringTransactionFormView(isPresented: .constant(true), transaction: transaction, onDismiss: {
                    transactionToEdit = nil
                })
            }
        }
    }
}

struct RecurringTransactionRow: View {
    @EnvironmentObject private var financeStore: FinanceStore
    var transaction: RecurringTransaction
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack {
            HStack {
                // Icon
                Image(systemName: transaction.type == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(transaction.type == .income ? ThemeColors.incomeGreen : ThemeColors.expenseRed)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.note.isEmpty ? (transaction.type == .income ? "Доход" : "Расход") : transaction.note)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.primaryText)
                    
                    if transaction.type == .expense, let category = transaction.category {
                        HStack(spacing: 4) {
                            Image(systemName: iconForCategory(category))
                                .font(.caption)
                            Text(category.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(ThemeColors.secondaryText)
                    }
                }
                
                Spacer()
                
                // Amount and frequency
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedAmount(for: transaction))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(transaction.type == .income ? ThemeColors.incomeGreen : ThemeColors.expenseRed)
                    
                    Text(transaction.frequency.rawValue)
                        .font(.caption)
                        .foregroundColor(ThemeColors.secondaryText)
                }
                
                // Delete button
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(ThemeColors.secondaryText)
                        .padding(.leading, 8)
                }
            }
            .padding()
            .background(ThemeColors.cardBackground)
            .cornerRadius(10)
            .padding(.horizontal)
            .alert("Удалить платеж?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Удалить", role: .destructive) {
                    financeStore.deleteRecurringTransaction(transaction.id)
                }
            } message: {
                Text("Вы уверены, что хотите удалить этот повторяющийся платеж?")
            }
        }
    }
    
    private func iconForCategory(_ category: Category) -> String {
        switch category {
        case .food: return "cart.fill"
        case .transport: return "car.fill"
        case .entertainment: return "tv.fill"
        case .utilities: return "bolt.fill"
        case .health: return "heart.fill"
        case .home: return "house.fill"
        case .education: return "book.fill"
        case .clothing: return "tag.fill"
        case .travel: return "airplane"
        case .pets: return "pawprint.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    private func formattedAmount(for transaction: RecurringTransaction) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        let prefix = transaction.type == .income ? "+" : "-"
        
        if let formattedAmount = formatter.string(from: NSNumber(value: transaction.amount)) {
            return "\(prefix)\(formattedAmount) ₽"
        } else {
            return "\(prefix)\(Int(transaction.amount)) ₽"
        }
    }
}

struct RecurringTransactionFormView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @Binding var isPresented: Bool
    @State private var transactionType: TransactionType = .expense
    @State private var selectedCategory: Category = .food
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var frequency: RecurrenceFrequency = .monthly
    
    var transaction: RecurringTransaction? = nil
    var onDismiss: (() -> Void)? = nil
    
    private var isEditing: Bool {
        transaction != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Type Selector
                        Picker("Тип", selection: $transactionType) {
                            Text("Расход").tag(TransactionType.expense)
                            Text("Доход").tag(TransactionType.income)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Сумма")
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.secondaryText)
                            
                            TextField("0", text: $amount)
                                .keyboardType(.numberPad)
                                .font(.title)
                                .foregroundColor(ThemeColors.primaryText)
                                .inputStyle()
                        }
                        .padding(.horizontal)
                        
                        // Category
                        if transactionType == .expense {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Категория")
                                    .font(.subheadline)
                                    .foregroundColor(ThemeColors.secondaryText)
                                
                                Picker("Категория", selection: $selectedCategory) {
                                    ForEach(Category.allCases) { category in
                                        Text(category.rawValue).tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(ThemeColors.primaryText)
                                .inputStyle()
                            }
                            .padding(.horizontal)
                        }
                        
                        // Frequency
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Частота повторения")
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.secondaryText)
                            
                            Picker("Частота", selection: $frequency) {
                                ForEach(RecurrenceFrequency.allCases) { frequency in
                                    Text(frequency.rawValue).tag(frequency)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal)
                        
                        // Note
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Примечание")
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.secondaryText)
                            
                            TextField("Примечание", text: $note)
                                .foregroundColor(ThemeColors.primaryText)
                                .inputStyle()
                        }
                        .padding(.horizontal)
                        
                        // Save Button
                        Button(action: saveTransaction) {
                            Text(isEditing ? "Обновить" : "Сохранить")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? ThemeColors.accent : ThemeColors.accent.opacity(0.5))
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(isEditing ? "Изменить платеж" : "Новый платеж")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                        onDismiss?()
                    }
                }
            }
        }
        .onAppear {
            // If editing, populate fields with transaction data
            if let transaction = transaction {
                transactionType = transaction.type
                amount = String(Int(transaction.amount))
                if let category = transaction.category {
                    selectedCategory = category
                }
                note = transaction.note
                frequency = transaction.frequency
            }
        }
    }
    
    private var isFormValid: Bool {
        if let doubleAmount = Double(amount), doubleAmount > 0 {
            return true
        }
        return false
    }
    
    private func saveTransaction() {
        guard let doubleAmount = Double(amount), doubleAmount > 0 else { return }
        
        if let existingTransaction = transaction {
            // Update existing
            let updatedTransaction = RecurringTransaction(
                id: existingTransaction.id,
                type: transactionType,
                amount: doubleAmount,
                category: transactionType == .expense ? selectedCategory : nil,
                note: note,
                frequency: frequency,
                startDate: existingTransaction.startDate,
                lastProcessedDate: existingTransaction.lastProcessedDate
            )
            
            financeStore.updateRecurringTransaction(updatedTransaction)
        } else {
            // Create new
            let newTransaction = RecurringTransaction(
                type: transactionType,
                amount: doubleAmount,
                category: transactionType == .expense ? selectedCategory : nil,
                note: note,
                frequency: frequency
            )
            
            financeStore.addRecurringTransaction(newTransaction)
        }
        
        isPresented = false
        onDismiss?()
    }
} 