import SwiftUI
import Combine

struct TransactionFormView: View {
    let type: TransactionType
    let onSave: (Transaction) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedCategory: Category = .food
    @State private var date = Date()
    @State private var useCustomDate = false
    @State private var isAmountValid = false
    
    private var isIncome: Bool {
        type == .income
    }
    
    private var formIsValid: Bool {
        isAmountValid
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Amount Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Сумма")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryText)
                            
                            TextField("", text: Binding(
                                get: { self.amount },
                                set: { newValue in
                                    // Filter non-numeric characters except for one decimal point
                                    let filtered = newValue.filter { "0123456789.,".contains($0) }
                                    
                                    // Only allow one decimal separator
                                    if filtered != newValue {
                                        self.amount = filtered
                                    } else {
                                        self.amount = newValue
                                    }
                                    
                                    // Replace comma with dot for consistent formatting
                                    let dotFormatted = self.amount.replacingOccurrences(of: ",", with: ".")
                                    
                                    // Check if there's more than one decimal point
                                    if dotFormatted.filter({ $0 == "." }).count > 1,
                                       let lastDot = dotFormatted.lastIndex(of: ".") {
                                        let formatted = dotFormatted.prefix(upTo: lastDot) + dotFormatted.suffix(from: dotFormatted.index(after: lastDot)).filter { $0 != "." }
                                        self.amount = String(formatted)
                                    }
                                    
                                    // Validate amount
                                    if let amountValue = Double(self.amount.replacingOccurrences(of: ",", with: ".")), amountValue > 0 {
                                        self.isAmountValid = true
                                    } else {
                                        self.isAmountValid = false
                                    }
                                }
                            ))
                                .keyboardType(.decimalPad)
                                .placeholder(when: amount.isEmpty) {
                                    Text("Введите сумму")
                                        .foregroundColor(ThemeColors.placeholderText)
                                }
                                .inputStyle()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isAmountValid || amount.isEmpty ? ThemeColors.primaryText.opacity(0.3) : ThemeColors.expenseRed, lineWidth: 1)
                                )
                            
                            if !amount.isEmpty && !isAmountValid {
                                Text("Введите корректную сумму")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.expenseRed)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Note
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Заметка")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryText)
                            
                            TextField("", text: $note)
                                .placeholder(when: note.isEmpty) {
                                    Text("Опционально")
                                        .foregroundColor(ThemeColors.placeholderText)
                                }
                                .inputStyle()
                        }
                        .padding(.horizontal)
                        
                        // Category (for expense only)
                        if !isIncome {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Категория")
                                    .font(.headline)
                                    .foregroundColor(ThemeColors.primaryText)
                                    .padding(.horizontal)
                                
                                CategoryGridView(selectedCategory: $selectedCategory)
                            }
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Дата")
                                    .font(.headline)
                                    .foregroundColor(ThemeColors.primaryText)
                                
                                Spacer()
                                
                                Toggle("", isOn: $useCustomDate)
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                            
                            if useCustomDate {
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .accentColor(ThemeColors.accent)
                                    .padding()
                                    .glassCard()
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Save Button
                        Button(action: saveTransaction) {
                            Text("Сохранить")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    formIsValid 
                                    ? (isIncome ? ThemeColors.incomeGreen : ThemeColors.expenseRed) 
                                    : Color.gray
                                )
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .disabled(!formIsValid)
                        .padding(.vertical)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(isIncome ? "Новый доход" : "Новый расход")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(ThemeColors.primaryText)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveTransaction() {
        // Convert string amount to Double, replacing comma with dot for localization
        let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0
        
        let transaction = Transaction(
            type: type,
            amount: amountValue,
            category: isIncome ? nil : selectedCategory,
            note: note,
            date: useCustomDate ? date : Date()
        )
        
        onSave(transaction)
        dismiss()
    }
}

// MARK: - CategoryGridView

struct CategoryGridView: View {
    @Binding var selectedCategory: Category
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Category.allCases) { category in
                CategoryCell(
                    category: category,
                    isSelected: selectedCategory == category,
                    action: { selectedCategory = category }
                )
            }
        }
        .padding(.horizontal)
    }
}

struct CategoryCell: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: iconForCategory(category))
                    .font(.system(size: 24))
                
                Text(category.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .padding(10)
            .foregroundColor(isSelected ? .white : ThemeColors.secondaryText)
            .background(isSelected ? colorForCategory(category) : ThemeColors.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? colorForCategory(category) : Color.clear, lineWidth: 2)
            )
        }
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

// MARK: - Extensions

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}