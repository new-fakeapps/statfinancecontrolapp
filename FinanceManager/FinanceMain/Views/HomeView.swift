import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var showingIncomeSheet = false
    @State private var showingExpenseSheet = false
    @State private var showingSuccessBanner = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Balance Card
                        BalanceCard(balance: financeStore.balance)
                            .padding(.horizontal)
                        
                        // Monthly Income Goal Card
                        MonthlyGoalCard()
                            .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            ActionButton(
                                title: "Добавить доход",
                                icon: "plus.circle.fill",
                                color: ThemeColors.incomeGreen
                            ) {
                                showingIncomeSheet = true
                            }
                            
                            ActionButton(
                                title: "Добавить расход",
                                icon: "minus.circle.fill",
                                color: ThemeColors.expenseRed
                            ) {
                                showingExpenseSheet = true
                            }
                        }
                        .padding(.horizontal)
                        
                        // Recent transactions
                        if financeStore.transactions.isEmpty {
                            Text("Нет операций")
                                .foregroundColor(ThemeColors.secondaryText)
                                .padding()
                                .glassCard()
                                .padding(.horizontal)
                        } else {
                            VStack(alignment: .leading) {
                                Text("Последние операции")
                                    .font(.headline)
                                    .foregroundColor(ThemeColors.primaryText)
                                    .padding(.horizontal)
                                
                                RecentTransactionsList(transactions: Array(financeStore.recentTransactions.prefix(3)))
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Финансы")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Force refresh data when view appears
                DispatchQueue.main.async {
                    financeStore.objectWillChange.send()
                }
            }
            .sheet(isPresented: $showingIncomeSheet) {
                TransactionFormView(type: .income, onSave: { transaction in
                    financeStore.addTransaction(transaction)
                    showSuccessBanner()
                })
            }
            .sheet(isPresented: $showingExpenseSheet) {
                TransactionFormView(type: .expense, onSave: { transaction in
                    financeStore.addTransaction(transaction)
                    showSuccessBanner()
                })
            }
            .overlay(
                SuccessBanner(isShowing: $showingSuccessBanner, message: "Операция добавлена")
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private func showSuccessBanner() {
        showingSuccessBanner = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingSuccessBanner = false
        }
    }
}

// MARK: - Supporting Views

struct BalanceCard: View {
    var balance: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Текущий баланс")
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
            
            Text(formattedBalance)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(balance >= 0 ? ThemeColors.incomeGreen : ThemeColors.expenseRed)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassCard()
    }
    
    private var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        return formatter.string(from: NSNumber(value: balance)) ?? "₽0.00"
    }
}

struct ActionButton: View {
    var title: String
    var icon: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.secondaryText)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(color)
            .background(color.opacity(0.15))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentTransactionsList: View {
    var transactions: [Transaction]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(transactions) { transaction in
                TransactionRow(transaction: transaction)
                    .padding(.horizontal)
                
                if transaction.id != transactions.last?.id {
                    Divider()
                        .background(ThemeColors.secondaryText.opacity(0.3))
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
        .glassCard()
        .padding(.horizontal)
    }
}

struct TransactionRow: View {
    var transaction: Transaction
    
    var body: some View {
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
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedAmount(for: transaction))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type == .income ? ThemeColors.incomeGreen : ThemeColors.expenseRed)
                
                Text(formattedDate(for: transaction))
                    .font(.caption)
                    .foregroundColor(ThemeColors.secondaryText)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formattedAmount(for transaction: Transaction) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        let prefix = transaction.type == .income ? "+" : "-"
        return prefix + (formatter.string(from: NSNumber(value: transaction.amount)) ?? "₽0.00")
    }
    
    private func formattedDate(for transaction: Transaction) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: transaction.date)
    }
    
    private func iconForCategory(_ category: Category) -> String {
        switch category {
        case .food:
            return "cart.fill"
        case .transport:
            return "car.fill"
        case .entertainment:
            return "film.fill"
        case .utilities:
            return "house.fill"
        case .health:
            return "heart.fill"
        case .home:
            return "house.circle.fill"
        case .education:
            return "book.fill"
        case .clothing:
            return "tshirt.fill"
        case .travel:
            return "airplane"
        case .pets:
            return "pawprint.fill"
        case .other:
            return "square.grid.2x2.fill"
        }
    }
}

struct SuccessBanner: View {
    @Binding var isShowing: Bool
    var message: String
    
    var body: some View {
        VStack {
            if isShowing {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text(message)
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                .zIndex(1)
                .animation(.spring(), value: isShowing)
            }
            Spacer()
        }
    }
}

// MARK: - Monthly Goal Card
struct MonthlyGoalCard: View {
    @EnvironmentObject private var financeStore: FinanceStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Цель по доходам на месяц")
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.secondaryText)
                
                Spacer()
                
                NavigationLink(destination: GoalsView()) {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(ThemeColors.accent)
                }
            }
            
            if let incomeGoal = financeStore.budgetGoals.monthlyIncomeGoal, incomeGoal > 0 {
                let progress = financeStore.getMonthlyIncomeGoalProgress()
                let currentIncome = financeStore.monthlyIncome()
                
                VStack(alignment: .leading, spacing: 8) {
                    ProgressBar(value: progress, color: progress >= 1.0 ? ThemeColors.incomeGreen : ThemeColors.accent)
                        .frame(height: 10)
                    
                    HStack {
                        Text("\(Int(currentIncome)) ₽")
                            .font(.headline)
                            .foregroundColor(ThemeColors.primaryText)
                        
                        Text("из \(Int(incomeGoal)) ₽")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.secondaryText)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.headline)
                            .foregroundColor(progress >= 1.0 ? ThemeColors.incomeGreen : ThemeColors.primaryText)
                    }
                }
            } else {
                HStack {
                    Text("Цель не установлена")
                        .foregroundColor(ThemeColors.secondaryText)
                    
                    Spacer()
                    
                    NavigationLink(destination: GoalsView()) {
                        Text("Установить")
                            .foregroundColor(ThemeColors.accent)
                    }
                }
            }
        }
        .padding()
        .glassCard()
    }
}