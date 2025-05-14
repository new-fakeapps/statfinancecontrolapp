import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var financeStore: FinanceStore
    
    // Добавляем инициализатор для вызова из UIKit
    init(financeStore: FinanceStore? = nil) {
        // Если FinanceStore передан напрямую, мы все равно будем
        // использовать @EnvironmentObject для его доступа в представлении
        if let store = financeStore {
            // Это просто заглушка для инициализатора
            // Фактическое присвоение произойдет через .environmentObject() в SplashScreenRouter
            print("MainTabView initialized with FinanceStore")
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
                .tag(0)
            
            RecurringTransactionsView()
                .tabItem {
                    Label("Повторения", systemImage: "repeat.circle")
                }
                .tag(1)
            
            GoalsView()
                .tabItem {
                    Label("Цели", systemImage: "target")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Label("Статистика", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .environmentObject(financeStore)
    }
}