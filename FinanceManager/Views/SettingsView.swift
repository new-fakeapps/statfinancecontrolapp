import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var showingConfirmationDialog = false
    @State private var showingAboutSheet = false
    @State private var showingHelpAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                List {
                    Section(header: Text("Данные").foregroundColor(ThemeColors.secondaryText)) {
                        Button(action: {
                            showingConfirmationDialog = true
                        }) {
                            Label("Очистить все данные", systemImage: "trash")
                                .foregroundColor(ThemeColors.primaryText)
                        }
                        .listRowBackground(ThemeColors.cardBackground)
                    }
                    
                    Section(header: Text("О приложении").foregroundColor(ThemeColors.secondaryText)) {
                        Button(action: {
                            showingAboutSheet = true
                        }) {
                            Label("О разработчике", systemImage: "person.circle")
                                .foregroundColor(ThemeColors.primaryText)
                        }
                        .listRowBackground(ThemeColors.cardBackground)
                        
                        Button(action: {
                            showingHelpAlert = true
                        }) {
                            Label("Помощь", systemImage: "questionmark.circle")
                                .foregroundColor(ThemeColors.primaryText)
                        }
                        .listRowBackground(ThemeColors.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .alert("Очистить все данные?", isPresented: $showingConfirmationDialog) {
                Button("Отмена", role: .cancel) {}
                Button("Очистить", role: .destructive) {
                    financeStore.transactions = []
                    financeStore.saveTransactions()
                }
            } message: {
                Text("Это действие нельзя отменить.")
            }
            .alert("Помощь", isPresented: $showingHelpAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Если у вас возникли вопросы или проблемы с приложением, пожалуйста, свяжитесь с нами по email: support@financemanager.com")
            }
            .sheet(isPresented: $showingAboutSheet) {
                AboutView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 80))
                            .foregroundColor(ThemeColors.accent)
                            .padding()
                        
                        Text("Финансовый Менеджер")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.primaryText)
                        
                        Text("Простое приложение для отслеживания доходов и расходов.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(ThemeColors.secondaryText)
                        
                        Divider()
                            .background(ThemeColors.secondaryText.opacity(0.3))
                            .padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Разработано с использованием:")
                                .font(.headline)
                                .foregroundColor(ThemeColors.primaryText)
                            
                            HStack {
                                Image(systemName: "swift")
                                    .foregroundColor(.orange)
                                Text("Swift")
                                    .foregroundColor(ThemeColors.primaryText)
                            }
                            
                            HStack {
                                Image(systemName: "applelogo")
                                    .foregroundColor(.gray)
                                Text("SwiftUI")
                                    .foregroundColor(ThemeColors.primaryText)
                            }
                        }
                        .padding()
                        .glassCard()
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Text("© 2025 Finance Manager App")
                            .font(.caption)
                            .foregroundColor(ThemeColors.secondaryText)
                    }
                    .padding()
                }
            }
            .navigationTitle("О приложении")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ThemeColors.secondaryText)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
