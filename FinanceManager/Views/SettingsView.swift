import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var showingConfirmationDialog = false
    @State private var showingAboutSheet = false
    @State private var showingHelpAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.darkBlue.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Data section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Данные")
                                .font(.headline)
                                .foregroundColor(ThemeColors.secondaryText)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            Button(action: {
                                showingConfirmationDialog = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(ThemeColors.primaryText)
                                    Text("Очистить все данные")
                                        .foregroundColor(ThemeColors.primaryText)
                                    Spacer()
                                }
                                .padding()
                                .background(ThemeColors.cardBackground)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        
                        // About section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("О приложении")
                                .font(.headline)
                                .foregroundColor(ThemeColors.secondaryText)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 1) {
                                Button(action: {
                                    showingAboutSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "person.circle")
                                            .foregroundColor(ThemeColors.primaryText)
                                        Text("О разработчике")
                                            .foregroundColor(ThemeColors.primaryText)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(ThemeColors.cardBackground)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    showingHelpAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "questionmark.circle")
                                            .foregroundColor(ThemeColors.primaryText)
                                        Text("Помощь")
                                            .foregroundColor(ThemeColors.primaryText)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(ThemeColors.cardBackground)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
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
                Text("Если вы столкнулись с проблемой пожалуйста, напишите нам на почту: financemanagerappsametfay@proton.me")
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
                        
                        Text("СтатФинанс: Контроль Бюджета")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.primaryText)
                        
                        Text("Просто приложение для отслеживания доходов и расходов.")
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
                        
                        Text("© 2025 StatFinance: Budget Control App")
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
