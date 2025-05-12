import SwiftUI

struct GoalsView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var incomeGoalInput: String = ""
    @State private var selectedCategory: Category = .food
    @State private var categoryLimitInput: String = ""
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Monthly Income Goal Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Цель по доходам")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryText)
                            
                            if let incomeGoal = financeStore.budgetGoals.monthlyIncomeGoal, incomeGoal > 0 {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Ежемесячная цель: ")
                                            .foregroundColor(ThemeColors.secondaryText)
                                        Text("\(Int(incomeGoal)) ₽")
                                            .foregroundColor(ThemeColors.primaryText)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            incomeGoalInput = "\(Int(incomeGoal))"
                                            showingEditSheet = true
                                        }) {
                                            Image(systemName: "pencil.circle")
                                                .foregroundColor(ThemeColors.accent)
                                        }
                                    }
                                    
                                    let progress = financeStore.getMonthlyIncomeGoalProgress()
                                    let currentIncome = financeStore.monthlyIncome()
                                    
                                    ProgressBar(value: progress, color: progress >= 1.0 ? ThemeColors.incomeGreen : ThemeColors.accent)
                                        .frame(height: 10)
                                    
                                    HStack {
                                        Text("Текущий доход: \(Int(currentIncome)) ₽")
                                            .font(.caption)
                                            .foregroundColor(ThemeColors.secondaryText)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(progress * 100))%")
                                            .font(.caption)
                                            .foregroundColor(ThemeColors.secondaryText)
                                    }
                                }
                            } else {
                                HStack {
                                    Text("Цель не установлена")
                                        .foregroundColor(ThemeColors.secondaryText)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        incomeGoalInput = ""
                                        showingEditSheet = true
                                    }) {
                                        Text("Установить")
                                            .foregroundColor(ThemeColors.accent)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(ThemeColors.cardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Category Limits Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Лимиты расходов по категориям")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryText)
                                .padding(.horizontal)
                            
                            // Add new limit
                            HStack {
                                Picker("Категория", selection: $selectedCategory) {
                                    ForEach(Category.allCases) { category in
                                        Text(category.rawValue).tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(ThemeColors.primaryText)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(ThemeColors.cardBackground)
                                .cornerRadius(10)
                                
                                TextField("Лимит", text: $categoryLimitInput)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(ThemeColors.primaryText)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(ThemeColors.cardBackground)
                                    .cornerRadius(10)
                                
                                Button(action: {
                                    if let limit = Double(categoryLimitInput), limit > 0 {
                                        financeStore.setCategoryLimit(category: selectedCategory, amount: limit)
                                        categoryLimitInput = ""
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(ThemeColors.accent)
                                        .font(.title2)
                                }
                                .disabled(categoryLimitInput.isEmpty)
                            }
                            .padding(.horizontal)
                            
                            // List of existing limits
                            VStack(spacing: 0) {
                                ForEach(Category.allCases) { category in
                                    if let limit = financeStore.budgetGoals.categoryLimits[category], limit > 0 {
                                        CategoryLimitRow(category: category, limit: limit)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal)
                                            .background(ThemeColors.cardBackground)
                                    }
                                }
                            }
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Цели и лимиты")
            .sheet(isPresented: $showingEditSheet) {
                IncomeGoalEditView(incomeGoalInput: $incomeGoalInput)
            }
        }
        .onAppear {
            // Initialize incomeGoalInput with current goal
            if let currentGoal = financeStore.budgetGoals.monthlyIncomeGoal, currentGoal > 0 {
                incomeGoalInput = "\(Int(currentGoal))"
            }
        }
    }
}

// Progress Bar
struct ProgressBar: View {
    var value: Double // between 0 and 1
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(color)
                    .animation(.linear, value: value)
            }
            .cornerRadius(45)
        }
    }
}

// Category Limit Row
struct CategoryLimitRow: View {
    @EnvironmentObject private var financeStore: FinanceStore
    var category: Category
    var limit: Double
    
    var body: some View {
        HStack {
            Image(systemName: iconForCategory(category))
                .foregroundColor(colorForCategory(category))
                .font(.headline)
            
            Text(category.rawValue)
                .foregroundColor(ThemeColors.primaryText)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let currentSpending = financeStore.monthlyExpenseByCategory(category: category)
                let isExceeded = currentSpending > limit
                
                Text("\(Int(currentSpending)) ₽ / \(Int(limit)) ₽")
                    .foregroundColor(isExceeded ? ThemeColors.expenseRed : ThemeColors.primaryText)
                    .font(.subheadline)
                
                ProgressBar(
                    value: min(currentSpending / limit, 1.0),
                    color: isExceeded ? ThemeColors.expenseRed : ThemeColors.accent
                )
                .frame(width: 100, height: 5)
            }
            
            Button(action: {
                financeStore.removeCategoryLimit(category: category)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(ThemeColors.secondaryText)
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
    
    private func colorForCategory(_ category: Category) -> Color {
        switch category {
        case .food: return .blue
        case .transport: return .green
        case .entertainment: return .purple
        case .utilities: return .orange
        case .health: return .red
        case .home: return .indigo
        case .education: return .teal
        case .clothing: return .pink
        case .travel: return .mint
        case .pets: return .brown
        case .other: return .gray
        }
    }
}

// Income Goal Edit View
struct IncomeGoalEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var financeStore: FinanceStore
    @Binding var incomeGoalInput: String
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Установите ежемесячную цель по доходам")
                        .font(.headline)
                        .foregroundColor(ThemeColors.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    TextField("Сумма в рублях", text: $incomeGoalInput)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(ThemeColors.cardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Text("Введите 0, чтобы удалить цель")
                        .font(.caption)
                        .foregroundColor(ThemeColors.secondaryText)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if let goalAmount = Double(incomeGoalInput), goalAmount > 0 {
                            financeStore.setMonthlyIncomeGoal(goalAmount)
                        } else {
                            // Set to nil or 0 to remove goal
                            financeStore.setMonthlyIncomeGoal(nil)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
} 