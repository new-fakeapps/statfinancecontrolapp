import SwiftUI

// MARK: - Monthly Expense Chart View
struct MonthlyExpenseChartView: View {
    var transactions: [Transaction]
    var timeFilter: StatsView.TimeFilter
    @State private var animateChart = false
    @State private var selectedMonth: String?
    
    // Группируем транзакции по месяцам
    private var monthlyData: [(month: String, amount: Double)] {
        let groupedByMonth = Dictionary(grouping: transactions) { transaction -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            return dateFormatter.string(from: transaction.date)
        }
        
        let sortedMonths = groupedByMonth.keys.sorted()
        
        // Берем последние 6 месяцев для лучшей визуализации
        let lastMonths = sortedMonths.suffix(6)
        
        // Суммируем расходы по каждому месяцу
        return lastMonths.map { month -> (month: String, amount: Double) in
            let monthTransactions = groupedByMonth[month] ?? []
            let totalAmount = monthTransactions.reduce(0) { $0 + $1.amount }
            
            // Форматируем название месяца
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            if let date = dateFormatter.date(from: month) {
                dateFormatter.dateFormat = "MMM yyyy"
                dateFormatter.locale = Locale(identifier: "ru_RU")
                return (dateFormatter.string(from: date), totalAmount)
            }
            
            return (month, totalAmount)
        }
    }
    
    // Максимальная сумма расходов (для масштабирования графика)
    private var maxAmount: Double {
        monthlyData.map { $0.amount }.max() ?? 0
    }
    
    // Общая сумма расходов
    private var totalExpense: Double {
        monthlyData.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if transactions.isEmpty {
                Text("Нет данных")
                    .foregroundColor(ThemeColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // Заголовок с общей суммой за период
                HStack {
                    Text("Расходы по месяцам")
                        .font(.headline)
                        .foregroundColor(ThemeColors.primaryText)
                        .overlay(
                            Text(timeFilter == .currentMonth ? "(текущий месяц)" : "")
                                .font(.caption)
                                .foregroundColor(ThemeColors.secondaryText)
                                .offset(y: 18)
                        , alignment: .bottom)
                    
                    Spacer()
                    
                    Text(formattedAmount(totalExpense))
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.primaryText)
                }
                
                // Вертикальный график
                HStack(alignment: .bottom, spacing: max(4, min(20, (UIScreen.main.bounds.width - 100) / CGFloat(monthlyData.count) / 2))) {
                    ForEach(monthlyData, id: \.month) { monthData in
                        VStack(spacing: 6) {
                            // Сумма за месяц
                            Text(formattedShortAmount(monthData.amount))
                                .font(.caption2)
                                .foregroundColor(ThemeColors.primaryText)
                                .opacity(selectedMonth == monthData.month || selectedMonth == nil ? 1.0 : 0.5)
                            
                            // Вертикальный столбец
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.6),
                                            Color.blue
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 24, height: animateChart ? getBarHeight(amount: monthData.amount) : 0)
                                .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 0, y: 2)
                                .opacity(selectedMonth == monthData.month || selectedMonth == nil ? 1.0 : 0.5)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateChart)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if selectedMonth == monthData.month {
                                            selectedMonth = nil
                                        } else {
                                            selectedMonth = monthData.month
                                        }
                                    }
                                }
                            
                            // Название месяца
                            Text(formatMonthLabel(monthData.month))
                                .font(.caption2)
                                .foregroundColor(ThemeColors.secondaryText)
                                .opacity(selectedMonth == monthData.month || selectedMonth == nil ? 1.0 : 0.5)
                                .rotationEffect(.degrees(-45))
                                .frame(height: 20)
                                .fixedSize()
                        }
                    }
                }
                .frame(height: 220)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .padding(.horizontal, 4)
                
                if let selectedMonth = selectedMonth, let monthData = monthlyData.first(where: { $0.month == selectedMonth }) {
                    HStack {
                        Text(selectedMonth)
                            .font(.caption)
                            .foregroundColor(ThemeColors.primaryText)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("Сумма: \(formattedAmount(monthData.amount))")
                            .font(.caption)
                            .foregroundColor(ThemeColors.primaryText)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(ThemeColors.cardBackground)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .glassCard()
        .onAppear {
            // Анимация появления столбцов на графике
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    animateChart = true
                }
            }
        }
        .onDisappear {
            animateChart = false
        }
    }
    
    // Форматируем сумму для отображения
    private func formattedAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "RUB"
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0.00"
    }
    
    // Упрощенное форматирование для меток столбцов
    private func formattedShortAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "₽"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₽0"
    }
    
    // Расчет высоты столбца в зависимости от максимальной суммы
    private func getBarHeight(amount: Double) -> CGFloat {
        if maxAmount <= 0 { return 0 }
        return CGFloat(amount / maxAmount) * 150
    }
    
    // Сокращаем название месяца для компактного отображения
    private func formatMonthLabel(_ monthStr: String) -> String {
        let components = monthStr.split(separator: " ")
        if components.count == 2, let month = components.first, let year = components.last {
            return "\(month.prefix(3))"
        }
        return monthStr
    }
} 