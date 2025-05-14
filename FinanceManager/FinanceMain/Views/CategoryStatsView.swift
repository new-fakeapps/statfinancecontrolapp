import SwiftUI

// MARK: - Category Stats View
struct CategoryStatsView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    var categoryData: [Category: Double]
    var timeFilter: StatsView.TimeFilter
    
    private var sortedCategories: [(Category, Double)] {
        categoryData.filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
    }
    
    private var totalExpenses: Double {
        sortedCategories.reduce(0) { $0 + $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Расходы по категориям\(timeFilter == .currentMonth ? " за текущий месяц" : "")")
                .font(.headline)
                .foregroundColor(ThemeColors.primaryText)
            
            if sortedCategories.isEmpty {
                Text("Нет данных по расходам")
                    .foregroundColor(ThemeColors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(sortedCategories), id: \.0) { (category, amount) in
                    let percentage = (amount / totalExpenses) * 100
                    let hasLimit = financeStore.budgetGoals.hasLimit(for: category)
                    let limit = financeStore.budgetGoals.categoryLimits[category] ?? 0
                    let isExceeded = hasLimit && amount > limit
                    
                    VStack(spacing: 8) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: iconForCategory(category))
                                    .foregroundColor(colorForCategory(category))
                                    .font(.system(size: 14))
                                
                                Text(category.rawValue)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.primaryText)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                // Show amount and percentage
                                Text(String(format: "%.0f ₽ (%.1f%%)", amount, percentage))
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.primaryText)
                                
                                // Show limit if exists
                                if hasLimit {
                                    HStack(spacing: 4) {
                                        Text("Лимит: \(Int(limit)) ₽")
                                            .font(.caption)
                                            .foregroundColor(isExceeded ? ThemeColors.expenseRed : ThemeColors.secondaryText)
                                        
                                        if isExceeded {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.caption)
                                                .foregroundColor(ThemeColors.expenseRed)
                                        }
                                    }
                                }
                            }
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 8)
                                
                                // Category expense bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isExceeded ? ThemeColors.expenseRed : colorForCategory(category))
                                    .frame(width: max(0, CGFloat(amount / (sortedCategories.first?.1 ?? 1)) * geometry.size.width), height: 8)
                                
                                // Limit indicator if exists
                                if hasLimit && limit > 0 {
                                    let limitPosition = min(CGFloat(limit / (sortedCategories.first?.1 ?? 1)) * geometry.size.width, geometry.size.width)
                                    
                                    Rectangle()
                                        .fill(isExceeded ? ThemeColors.expenseRed : ThemeColors.accent)
                                        .frame(width: 2, height: 12)
                                        .position(x: limitPosition, y: 4)
                                }
                            }
                        }
                        .frame(height: 8)
                    }
                }
                
                Divider()
                    .background(ThemeColors.secondaryText.opacity(0.3))
                    .padding(.vertical, 4)
                
                HStack {
                    Text("Итого:")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.primaryText)
                    
                    Spacer()
                    
                    Text(String(format: "%.0f ₽", totalExpenses))
                        .font(.headline)
                        .foregroundColor(ThemeColors.primaryText)
                }
            }
        }
        .padding()
        .glassCard()
        .transition(.opacity)
    }
    
    // Вспомогательные функции для отображения иконок и цветов категорий
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