//
//  FinanceManagerApp.swift
//  FinanceManager
//
//  Created by Artem on 09.04.2025.
//

import SwiftUI

@main
struct FinanceManagerApp: App {
    @StateObject private var financeStore = FinanceStore()
    @AppStorage("isDarkMode") private var isDarkMode = true // Default to dark mode
    
    var body: some Scene {
        WindowGroup {
            ForceCompactView(content: MainTabView())
                .environmentObject(financeStore)
                .preferredColorScheme(.dark)
        }
    }
}

struct ForceCompactView<Content: View>: View {
    let content: Content
    
    var body: some View {
        content
            .environment(\.horizontalSizeClass, .compact)
    }
}
