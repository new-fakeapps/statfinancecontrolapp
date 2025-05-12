import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var selectedFilter: TransactionFilter = .all
    @State private var chartType: ChartDisplayType = .table
    @State private var timeFilter: TimeFilter = .allTime
    
    enum TransactionFilter {
        case all, income, expense
    }
    
    enum ChartDisplayType {
        case table, chart
    }
    
    enum TimeFilter: String, CaseIterable {
        case allTime = "Всё время"
        case currentMonth = "Текущий месяц"
    }
    
    // Фильтрация транзакций по выбранному временному периоду
    private var filteredByTimeTransactions: [Transaction] {
        switch timeFilter {
        case .allTime:
            return financeStore.transactions
        case .currentMonth:
            return financeStore.transactions.filter { transaction in
                Calendar.current.isDate(transaction.date, equalTo: Date(), toGranularity: .month)
            }
        }
    }
    
    // Расчет баланса, доходов и расходов с учетом временного фильтра
    private var filteredIncome: Double {
        filteredByTimeTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var filteredExpense: Double {
        filteredByTimeTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    private var filteredBalance: Double {
        filteredIncome - filteredExpense
    }
    
    // Получение расходов по категориям с учетом временного фильтра
    private func filteredExpensesByCategory() -> [Category: Double] {
        let expenseTransactions = filteredByTimeTransactions.filter { $0.type == .expense }
        var result: [Category: Double] = [:]
        
        for category in Category.allCases {
            result[category] = 0
        }
        
        for transaction in expenseTransactions {
            if let category = transaction.category {
                result[category, default: 0] += transaction.amount
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Переключатель временного периода
                        Picker("", selection: $timeFilter) {
                            ForEach(TimeFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Financial Summary - используем фильтрованные данные
                        FinancialSummaryView(
                            income: filteredIncome,
                            expense: filteredExpense,
                            balance: filteredBalance
                        )
                        .padding(.horizontal)
                        
                        // Expense by Category - используем фильтрованные данные
                        let hasExpenses = filteredByTimeTransactions.contains(where: { $0.type == .expense })
                        
                        if hasExpenses {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Расходы по категориям")
                                        .font(.headline)
                                        .foregroundColor(ThemeColors.primaryText)
                                    
                                    Spacer()
                                    
                                    // Компактный сегментированный контрол с иконками
                                    ZStack {
                                        Capsule()
                                            .fill(Color.blue)
                                            .frame(width: 90, height: 36)
                                        
                                        HStack(spacing: 0) {
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    chartType = .table
                                                }
                                            }) {
                                                Image(systemName: "list.bullet")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .frame(width: 45, height: 36)
                                                    .background(chartType == .table ? Color.white.opacity(0.3) : Color.clear)
                                                    .clipShape(Capsule())
                                            }
                                            
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    chartType = .chart
                                                }
                                            }) {
                                                Image(systemName: "chart.bar.fill")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .frame(width: 45, height: 36)
                                                    .background(chartType == .chart ? Color.white.opacity(0.3) : Color.clear)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                    .frame(width: 90, height: 36)
                                }
                                .padding(.horizontal)
                                
                                if chartType == .table {
                                    CategoryStatsView(
                                        categoryData: filteredExpensesByCategory(),
                                        timeFilter: timeFilter
                                    )
                                    .transition(.opacity)
                                    .padding(.horizontal)
                                } else {
                                    MonthlyExpenseChartView(
                                        transactions: filteredByTimeTransactions.filter { $0.type == .expense },
                                        timeFilter: timeFilter
                                    )
                                    .transition(.opacity)
                                    .padding(.horizontal)
                                }
                            }
                        } else {
                            VStack {
                                Text("Нет расходов")
                                    .font(.headline)
                                    .foregroundColor(ThemeColors.primaryText)
                                
                                Text(timeFilter == .currentMonth ? "за текущий месяц" : "за всё время")
                                    .font(.subheadline)
                                    .foregroundColor(ThemeColors.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .glassCard()
                            .padding(.horizontal)
                        }
                        
                        // Transaction Filter
                        Picker("Filter", selection: $selectedFilter) {
                            Text("Все").tag(TransactionFilter.all)
                            Text("Доходы").tag(TransactionFilter.income)
                            Text("Расходы").tag(TransactionFilter.expense)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Transaction List - используем фильтрованные по типу и времени данные
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Операции")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryText)
                                .padding(.horizontal)
                            
                            if filteredTransactions.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack {
                                        Text("Нет операций")
                                            .foregroundColor(ThemeColors.secondaryText)
                                        
                                        Text(timeFilter == .currentMonth ? "за текущий месяц" : "")
                                            .font(.caption)
                                            .foregroundColor(ThemeColors.secondaryText)
                                    }
                                    .padding()
                                    Spacer()
                                }
                                .glassCard()
                                .padding(.horizontal)
                            } else {
                                ForEach(filteredTransactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .padding(.horizontal)
                                    
                                    if transaction.id != filteredTransactions.last?.id {
                                        Divider()
                                            .background(ThemeColors.secondaryText.opacity(0.3))
                                            .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical, 8)
                                .glassCard()
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Статистика")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
    }
    
    private var filteredTransactions: [Transaction] {
        let timeFilteredTransactions = filteredByTimeTransactions
        
        switch selectedFilter {
        case .all:
            return timeFilteredTransactions.sorted(by: { $0.date > $1.date })
        case .income:
            return timeFilteredTransactions.filter { $0.type == .income }.sorted(by: { $0.date > $1.date })
        case .expense:
            return timeFilteredTransactions.filter { $0.type == .expense }.sorted(by: { $0.date > $1.date })
        }
    }
}

// MARK: - Category Chart View
struct CategoryChartView: View {
    var categoryData: [Category: Double]
    @State private var animateChart = false
    
    private var sortedCategories: [(Category, Double)] {
        categoryData.filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
    }
    
    private var totalExpense: Double {
        sortedCategories.reduce(0) { $0 + $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if sortedCategories.isEmpty {
                Text("Нет данных")
                    .foregroundColor(ThemeColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // Заголовок с легендой
                HStack {
                    Text("Категория")
                        .font(.caption)
                        .foregroundColor(ThemeColors.secondaryText)
                    
                    Spacer()
                    
                    Text("Сумма / %")
                        .font(.caption)
                        .foregroundColor(ThemeColors.secondaryText)
                }
                .padding(.horizontal, 4)
                
                // График расходов
                ForEach(sortedCategories, id: \.0) { category, amount in
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            // Category icon
                            Image(systemName: iconForCategory(category))
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                                .padding(6)
                                .background(colorForCategory(category))
                                .clipShape(Circle())
                            
                            // Category name
                            Text(category.rawValue)
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(ThemeColors.primaryText)
                            
                            Spacer()
                            
                            // Amount and percentage
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(formattedAmount(amount))
                                    .font(.subheadline)
                                    .foregroundColor(ThemeColors.primaryText)
                                
                                Text("\(String(format: "%.1f", (amount / totalExpense) * 100))%")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.secondaryText)
                            }
                        }
                        
                        // Bar chart
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background bar
                                Capsule()
                                    .fill(ThemeColors.cardBackground)
                                    .frame(height: 14)
                                
                                // Value bar with animation
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [colorForCategory(category).opacity(0.7), colorForCategory(category)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: animateChart ? (CGFloat(amount) / CGFloat(totalExpense)) * geometry.size.width : 0, height: 14)
                                    .shadow(color: colorForCategory(category).opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                        }
                        .frame(height: 14)
                    }
                    .padding(.vertical, 4)
                }
                
                // Легенда внизу - показываем только если есть данные
                if !sortedCategories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Итого:")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.primaryText)
                        
                        Text(formattedAmount(totalExpense))
                            .font(.headline)
                            .foregroundColor(ThemeColors.primaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .glassCard()
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateChart = true
            }
        }
        .onDisappear {
            animateChart = false
        }
    }
    
    private func formattedAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0.00"
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
    
    private func colorForCategory(_ category: Category) -> Color {
        switch category {
        case .food:
            return .blue
        case .transport:
            return .green
        case .entertainment:
            return .purple
        case .utilities:
            return .orange
        case .health:
            return .red
        case .home:
            return .indigo
        case .education:
            return .teal
        case .clothing:
            return .pink
        case .travel:
            return .mint
        case .pets:
            return .brown
        case .other:
            return .gray
        }
    }
}

// MARK: - Financial Summary View
struct FinancialSummaryView: View {
    var income: Double
    var expense: Double
    var balance: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Финансовый обзор")
                .font(.headline)
                .foregroundColor(ThemeColors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                // Income
                SummaryItem(
                    title: "Доходы",
                    amount: income,
                    icon: "arrow.down.circle.fill",
                    color: ThemeColors.incomeGreen
                )
                
                Divider()
                    .background(ThemeColors.secondaryText.opacity(0.3))
                
                // Expense
                SummaryItem(
                    title: "Расходы",
                    amount: expense,
                    icon: "arrow.up.circle.fill",
                    color: ThemeColors.expenseRed
                )
                
                Divider()
                    .background(ThemeColors.secondaryText.opacity(0.3))
                
                // Balance
                SummaryItem(
                    title: "Баланс",
                    amount: balance,
                    icon: "creditcard.fill",
                    color: balance >= 0 ? ThemeColors.accent : ThemeColors.expenseRed
                )
            }
        }
        .padding()
        .glassCard()
    }
}

struct SummaryItem: View {
    var title: String
    var amount: Double
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(ThemeColors.secondaryText)
            
            Text(formattedAmount)
                .font(.headline)
                .foregroundColor(ThemeColors.primaryText)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0.00"
    }
}

// MARK: - Monthly Expense Chart View
